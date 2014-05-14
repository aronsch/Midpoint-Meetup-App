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
#import "CENSearchResult.h"

@interface CENLocationController () <CLLocationManagerDelegate>

@property (nonatomic)CLLocationManager *locationManager;
@property (readwrite, nonatomic) CLLocation *userLocation;
@property (nonatomic) NSOperationQueue *operationQueue;

@end

@implementation CENLocationController


-(id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = CENDefaultLocationDelta;
    _operationQueue = [[NSOperationQueue alloc] init];
    [self subscribeToNotifications];
    
    return self;
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
        
        // TODO
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
    
    [self.operationQueue addOperation:geocodeOperation];
}

#pragma mark - ETA Request Dispatch

-(void)dispatchETARequest:(MKDirectionsRequest *)etaRequest
                 andCompletionBlock:(void (^)(MKETAResponse *response))completionBlock {
    NSBlockOperation *etaOperation = [NSBlockOperation blockOperationWithBlock:^{
        
        MKDirections *directionSvc = [[MKDirections alloc] initWithRequest:etaRequest];
        NSLog(@"ETA request dispatched for %@, desination %@",etaRequest.source.name,etaRequest.destination.name);
        [directionSvc
         calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
            if (!error) {
                completionBlock(response);
            }
        }];
    }];
    
    [self.operationQueue addOperation:etaOperation];
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
    [self subscribeToETARequestNotification];
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

- (void)subscribeToETARequestNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENETARequestedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[MKDirectionsRequest class]]) {
             
             MKDirectionsRequest *etaRequest = (MKDirectionsRequest *)object;
             
             if (!etaRequest.destination) {
                 [NSException exceptionWithName:@"MKDirectionsRequest Missing Destination Property"
                                         reason:@"CENETANeeded notification listener expected a MKDirectionsRequest object with a non-nil Destination value."
                                       userInfo:nil];
             }
             if (!etaRequest.source) {
                 [NSException exceptionWithName:@"MKDirectionsRequest Missing Source Property"
                                         reason:@"CENETANeeded notification listener expected a MKDirectionsRequest object with a non-nil Source value."
                                       userInfo:nil];
             }
             
             // dispatch ETA request with completion handler
             [self dispatchETARequest:etaRequest
                   andCompletionBlock:^(MKETAResponse *response) {
                       // emit notification with results
                       NSLog(@"emitted %@ for %@", cnCENETAReturnedNotification, etaRequest.source.name);
                       [[NSNotificationCenter defaultCenter] postNotificationName:cnCENETAReturnedNotification object:response];
             }];
           
         }
         else {
             [CENCommon exceptionPayloadClassExpected:[MKDirectionsRequest class]
                                      forNotification:notification];
         }
     }];
}

@end
