//
//  CENContactMidpointOverlay.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactMidpointOverlay.h"
#import "CENCommon.h"

@interface CENContactMidpointOverlay ()

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite) MKMapRect boundingMapRect;

@end


@implementation CENContactMidpointOverlay


-(id)initWithCoordinate {
    self = [super init];
    if (!self) {
        return nil;
    }
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andBoundingMapRect:(MKMapRect)mapRect {
    self = [super init];
    if (!self) {
        return nil;
    }
    _coordinate = coordinate;
    _boundingMapRect = mapRect;
    return self;
}
@end
