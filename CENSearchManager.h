//
//  CENSearchManager.h
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CENSearchManager : NSObject

typedef enum {
    kCheap,
    kAverage,
    kExpensive,
    kNoSelection
} COAPriceOption;

typedef enum {
    kStrictOverlap,
    kNearbyOverlap,
    kLooseOverlap
} COAOverlapOption;


#pragma mark Search Inputs
- (void)setUserKeyword:(NSString *)keyword;
- (void)setPlaceTypesSelected:(NSArray *)itemIndexes;
- (void)setPriceOption:(COAPriceOption)priceOption;
- (void)setOverlapOption:(COAOverlapOption)overlapOption;

#pragma mark Place Type List Datasource
- (NSArray *)placeTypes;

#pragma mark - Searching
- (void)search;
- (void)newSearch;

#pragma mark - Utility

- (COAOverlapOption)overlapOption;


@end
