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

+(instancetype)annotationForResult:(CENSearchResult *)searchResult {
    return [[self alloc] initWithSearchResult:searchResult];
}

-(id)initWithSearchResult:(CENSearchResult *)searchResult {
    self = [super init];
    if (!self) {
        return nil;
    }
    _searchResult = searchResult;
    _coordinate = searchResult.placemark.coordinate;
    _title = searchResult.placemark.name;
    return self;
}

-(BOOL)isEqual:(id)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return [self isEqualToResultAnnotation:object];
}

-(BOOL)isEqualToResultAnnotation:(CENSearchResultAnnotation *)object {
    return [self.searchResult isEqual:object.searchResult];
}

@end
