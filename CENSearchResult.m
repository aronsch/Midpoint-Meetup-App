//
//  CENSearchResult.m
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import Foundation;
@import MapKit;
#import "CENSearchResult.h"

@interface CENSearchResult ()

@property (nonatomic) MKMapItem *mapItem;
@property (readwrite,nonatomic) NSMutableDictionary *etaToContacts;

@end

@implementation CENSearchResult

+(instancetype)resultWithMapItem:(MKMapItem *)mapItem {
    return [[CENSearchResult alloc] initWithMapItem:mapItem];
}

-(instancetype)initWithMapItem:(MKMapItem *)mapItem {
    self = [super init];
    if (!self) {
        return nil;
    }
    _mapItem = mapItem;
    _placemark = mapItem.placemark;
    _name = mapItem.name;
    _url = mapItem.url;
    return self;
}

-(BOOL)isEqual:(id)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return [self isEqualToResult:object];
}

-(BOOL)isEqualToResult:(CENSearchResult *)result {
    return ([self hash] == [result hash]);
}

-(NSUInteger)hash {
    return [[NSString stringWithFormat:@"CENSearchResult%@%f%f",
            self.placemark.name,
            self.placemark.coordinate.latitude,
            self.placemark.coordinate.longitude] hash];
}

@end
