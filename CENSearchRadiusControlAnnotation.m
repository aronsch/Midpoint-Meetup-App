//
//  CENSearchAreaAnnotation.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchRadiusControlAnnotation.h"
#import "CENCommon.h"

@implementation CENSearchRadiusControlAnnotation

+(instancetype)annotationWithLocation:(CLLocation *)location {
    return [[CENSearchRadiusControlAnnotation alloc] initWithLocation:location];
}

-(id)initWithLocation:(CLLocation *)location {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self setCoordinate:location.coordinate];
    
    
    return self;
}

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    _coordinate = newCoordinate;
}

-(void)setLocation:(CLLocation *)location {
    [self setCoordinate:CLLocationCoordinate2DWithLocation(location)];
}

-(CLLocation *)annotationLocation {
    return CLLocationMake(self.coordinate.latitude, self.coordinate.longitude);
}

@end
