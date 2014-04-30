//
//  CENContactsMidpointAnnotation.m
//  Center
//
//  Created by Aron Schneider on 4/20/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactsMidpointAnnotation.h"
#import "CENCommon.h"

@implementation CENContactsMidpointAnnotation

+(instancetype)annotationWithLocation:(CLLocation *)location {
    return [[CENContactsMidpointAnnotation alloc] initWithLocation:location];
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
