//
//  CENSearchRadiusControlAnnotation.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchRadiusControlAnnotation.h"
#import "CENCommon.h"

@implementation CENSearchRadiusControlAnnotation

@synthesize coordinate = _coordinate;

+(instancetype)annotationWithLocation:(CLLocation *)location {
    return [[CENSearchRadiusControlAnnotation alloc] initWithLocation:location];
}

-(id)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setHasBeenMoved:NO];
    [self setCoordinate:location.coordinate];
    
    
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setHasBeenMoved:NO];
    [self setCoordinate:coord];
    
    
    return self;
}

-(void)setLocation:(CLLocation *)location {
    [self setCoordinate:CLLocationCoordinate2DWithLocation(location)];
}

-(CLLocation *)annotationLocation {
    return CLLocationMake(self.coordinate.latitude, self.coordinate.longitude);
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}


@end
