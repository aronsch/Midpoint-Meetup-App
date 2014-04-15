//
//  CENLocationManager.m
//  Center
//
//  Created by Aron Schneider on 4/11/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENLocationManager.h"
#import <CoreLocation/CoreLocation.h>
#import "CENCommon.h"

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
    [self.locationManager setDistanceFilter:CENDefaultLocationDelta];
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

#pragma mark - Geocoding Services

-(void)geocodeAddress:(NSString *)address
                   completionBlock:(void (^)(BOOL succeeded, CLPlacemark*))completionBlock {
    
    // geoCode block variable for async dispatch
    NSBlockOperation *geocodeOperation = [NSBlockOperation blockOperationWithBlock: ^{
        CLGeocoder *gc = [[CLGeocoder alloc] init];
        
        [gc geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && placemarks) {
                CLPlacemark *placemark = [placemarks firstObject];
                completionBlock(YES,placemark);
            }
            else {
                completionBlock(NO,nil);
            }
        }];
    }];
    
    NSOperationQueue *geoQueue = [NSOperationQueue new];
    [geoQueue addOperation:geocodeOperation];
}

#pragma mark - Notifications

- (void)emitUserLocationUpdatedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:nCENUserLocationUpdatedNotification object:nil];
}

@end
