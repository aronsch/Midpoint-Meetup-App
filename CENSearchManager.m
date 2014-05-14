//
//  CENSearchManager.m
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchManager.h"
#import "CENCommon.h"
#import "CENSearchResult.h"

@interface CENSearchManager ()

@property (copy, nonatomic) NSString *userKeyword;
@property (copy, nonatomic) NSArray *placeTypesSelected;
@property (nonatomic) COAPriceOption priceOption;
@property (nonatomic) COAOverlapOption overlapOption;
@property (nonatomic) BOOL isNewSearch;

@property (nonatomic) NSMutableSet *searchResults;

@property (nonatomic) MKCoordinateRegion searchRegion;

@end

@implementation CENSearchManager

-(instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _placeTypes = CENPlaceTypesArray;
    [self subscribeToSearchRegionChangedNotification];
    return self;
}

#pragma mark - Search Control

- (void)newSearch {
    self.isNewSearch = YES;
    [self emitSearchZeroedNotification];
    [self search];
}

- (void)search {
    MKLocalSearch *search = [[MKLocalSearch alloc]
                             initWithRequest:[self searchRequest]];
    
    __weak CENSearchManager *weakSelf = self;
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {

        if (!error) {
            NSMutableSet *resultsSet = [NSMutableSet setWithArray:response.mapItems];
            [weakSelf updateSearchResultsWithSearchResponseItems:resultsSet];
        }
        else {
            // TODO: Error handling
        }
    }];
}

#pragma mark - Search Request Creation

- (MKLocalSearchRequest *)searchRequest {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    searchRequest.naturalLanguageQuery = [self queryString];
    searchRequest.region = self.searchRegion;
    return searchRequest;
}

-(NSString *)queryString {
    NSString *queryString = [[NSString alloc] init];
    NSString *userKeyword = !self.userKeyword ? @"" : self.userKeyword;
    queryString = [queryString stringByAppendingFormat:@"%@", userKeyword];
    
    for (NSString *placeType in [self placeTypesSelectedAsStringValues]) {
        queryString = [queryString stringByAppendingFormat:@" %@", placeType];
    }
    
    return queryString;
}

#pragma mark - Search Result Management

- (void)updateSearchResultsWithSearchResponseItems:(NSMutableSet *)responseItems {
    NSMutableSet *searchResults = [[NSMutableSet alloc] init];
    for (MKMapItem *mapItem in responseItems) {
        [searchResults addObject:[CENSearchResult resultWithMapItem:mapItem]];
    }
    
    if (self.isNewSearch) {
        [self emitSearchZeroedNotification];
        self.isNewSearch = NO;
        self.searchResults = searchResults;
        [self emitNewSearchResultsNotificationWithResults:searchResults];
    }
    else {
        [self addSearchResults:searchResults];
    }
}

- (NSSet *)newResultsForResults:(NSMutableSet *)searchResults {
    [searchResults intersectSet:self.searchResults];
    return [NSSet setWithSet:searchResults];
}

- (void)addSearchResults:(NSSet *)searchResults {

    if ([searchResults count] > 0) {
        NSMutableSet *addedResults = [NSMutableSet setWithSet:self.searchResults];
        
        // determine results not in existing results set
        [addedResults minusSet:searchResults];
        if (addedResults.count > 0) {
            // dispatch notification containing new results
            [self emitNewSearchResultsNotificationWithResults:addedResults];
            
            // merge new results into current result set
            [self.searchResults unionSet:searchResults];
            
        }
    }
}

# pragma mark - Place Types Data


- (NSArray *)placeTypesSelectedAsStringValues {
    NSMutableArray *strings = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in [self placeTypesSelected]) {
        [strings addObject:(NSString *)self.placeTypes[(NSUInteger)indexPath.item]];
    }
    return strings;
}

#pragma mark - Notification Emission 

- (void)emitNewSearchResultsNotificationWithResults:(NSSet *)newResults {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENSearchResultsAdded object:newResults];
}

- (void)emitSearchZeroedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENSearchZeroed object:nil];
}

#pragma mark - Notification Subscription 

- (void)subscribeToSearchRegionChangedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENSearchRegionChangedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[NSValue class]]) {
             self.searchRegion = [CENCommon regionFromValue:object];
         }
     }];
}

#pragma mark - Custom Setters

-(void)setUserKeyword:(NSString *)keyword {
    if (![keyword isEqualToString:_userKeyword]) {
        self.isNewSearch = YES;
    }
    _userKeyword = keyword;
}

@end
