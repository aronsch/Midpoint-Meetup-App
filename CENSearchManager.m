//
//  CENSearchManager.m
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchManager.h"
#import "CENCommon.h"

@interface CENSearchManager ()

@property (nonatomic) NSArray *placeTypes;
@property (copy, nonatomic) NSString *userKeyword;
@property (copy, nonatomic) NSArray *placeTypesSelected;
@property (nonatomic) COAPriceOption priceOption;
@property (nonatomic) COAOverlapOption overlapOption;
@property (nonatomic) BOOL isNewSearch;

@property (nonatomic) NSMutableArray *searchResults;

@property (nonatomic) MKCoordinateRegion searchRegion;

@end

@implementation CENSearchManager

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _placeTypes = CENPlaceTypesArray;
    return self;
}

- (void)newSearch {
    self.isNewSearch = YES;
    [self emitSearchZeroedNotification];
    [self search];
}

- (void)search {
    MKLocalSearch *search = [[MKLocalSearch alloc]
                             initWithRequest:[self searchRequest]];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response,
                                         NSError *error) {
        if (!error) {
            NSMutableArray *results = [NSMutableArray
                                       arrayWithArray:[response mapItems]];
            [self setSearchResults:results];
        }
    }];
}

- (MKLocalSearchRequest *)searchRequest {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = [self queryString];
    searchRequest.region = self.searchRegion;
    return searchRequest;
}

-(NSString *)queryString {
    NSString *queryString = [[NSString alloc] init];
    [queryString stringByAppendingFormat:@"%@", [self userKeyword]];
    
    for (NSString *placeType in [self placeTypesSelectedAsStringValues]) {
        [queryString stringByAppendingFormat:@" %@", placeType];
    }
    
    return queryString;
}

- (void)updateSearchResultsWithResults:(NSArray *)searchResults {
    if (self.isNewSearch) {
        self.searchResults = [NSMutableArray arrayWithArray:searchResults];
        self.isNewSearch = NO;
    }
    else {
        [self addSearchResults:searchResults];
    }
}

- (NSArray *)newResultsForResults:(NSArray *)searchResults {
    NSMutableSet *newResultSet = [NSMutableSet setWithArray:searchResults];
    NSSet *currentResultSet = [NSSet setWithArray:self.searchResults];
    [newResultSet intersectSet:currentResultSet];
    return [newResultSet allObjects];
}

- (void)addSearchResults:(NSArray *)searchResults {
    NSArray *newResults = [self newResultsForResults:searchResults];
    if ([newResults count] > 0) {
        [self emitNewSearchResultsNotificationWithResults:newResults];
    }
}

# pragma mark - Place Types Data

-(NSArray *)placeTypes {
    return self.placeTypes;
}

- (NSArray *)placeTypesSelectedAsStringValues {
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [self placeTypesSelected]) {
        [strings addObject:(NSString *)self.placeTypes[(NSUInteger)indexPath.item]];
    }
    return strings;
}

#pragma mark - Notification Emission 

- (void)emitNewSearchResultsNotificationWithResults:(NSArray *)newResults {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENSearchResultsAdded object:newResults];
}

- (void)emitSearchZeroedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENSearchZeroed object:nil];
}

@end
