//
//  CENLocationManager.m
//  Center
//
//  Created by Aron Schneider on 4/11/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface CENLocationManager () <CLLocationManagerDelegate>

@property (strong, nonatomic)CLLocationManager *locationManager;
@property (readwrite, strong, nonatomic) CLLocation *userLocation;

@end

@implementation CENLocationManager

-(id)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (void)configure {
    [self setLocationManager:[[CLLocationManager alloc] init]];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setDistanceFilter:100];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self setUserLocation:newLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([error code] != kCLErrorLocationUnknown) {
        //        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

#pragma mark - Location Tracking Start/Stop

-(void)beginUpdatingLocation {
    [self.locationManager startUpdatingLocation];
}

-(void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

@end
