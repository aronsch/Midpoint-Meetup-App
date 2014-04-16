//
//  CENSearchResultAnnotation.m
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchResultAnnotation.h"
#import <MapKit/MapKit.h>
#import "CENSearchResult.h"

@implementation CENSearchResultAnnotation

+(instancetype)annotationForSearchResult:(CENSearchResult *)searchResult {
    return [[self alloc] initWithSearchResult:searchResult];
}

-(id)initWithSearchResult:(CENSearchResult *)searchResult {
    self = [super init];
    if (!self) {
        return nil;
    }
    _searchResult = searchResult;
    [self configure];
    return self;
}

- (void)configure {
    [self setTitle:self.searchResult.name];
    [self setSubtitle:@""];
}

@end
