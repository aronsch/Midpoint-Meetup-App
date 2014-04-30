//
//  CENLocationManager.m
//  Center
//
//  Created by Aron Schneider on 4/11/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENLocationController.h"
#import <CoreLocation/CoreLocation.h>
#import "CENCommon.h"

@interface CENLocationController () <CLLocationManagerDelegate>

@property (strong, nonatomic)CLLocationManager *locationManager;
@property (readwrite, strong, nonatomic) CLLocation *userLocation;

@end

@implementation CENLocationController


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
    [self subscribeToNotifications];
}

#pragma mark - CLLocationManagerDelegate Methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self setUserLocation:newLocation];
    
}

-(void)setUserLocation:(CLLocation *)userLocation {
    _userLocation = userLocation;
    [self emitUserLocationUpdatedNotification];
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

#pragma mark - Geocoding Request Dispatch

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

#pragma mark - Notification Emission

- (void)emitUserLocationUpdatedNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:cnCENUserLocationUpdatedNotification
     object:self.userLocation];
}

#pragma mark - Notification Handling

- (void)subscribeToNotifications {
    [self subscribeToGeocodingRequestNotification];
}

- (void)subscribeToGeocodingRequestNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENGeocodeRequestedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         if ([notification.object conformsToProtocol:@protocol(CENGeoInformationProtocol)]) {

             __block NSObject<CENGeoInformationProtocol> *object = notification.object;
             
             [self geocodeAddress:[object addressAsString] completionBlock:^(BOOL succeeded, CLPlacemark *placemark) {
                 if (succeeded) {
                     [object setLocation:placemark.location];
                 }
             }];
         }
         else {
             // Raise Protocol Exception
             [CENCommon exceptionObjectDoesNotConformToCENGeoInformationProtocol:notification.object];
         }
     }];
}

@end
