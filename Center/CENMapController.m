//
//  CENMapController.m
//  Center
//
//  Created by Aron Schneider on 4/14/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENMapController.h"
#import "CENCommon.h"
#import "CENContact.h"
#import <MapKit/MapKit.h>

@interface CENMapController ()

@property (strong, nonatomic) id delegate;

@end

@implementation CENMapController

- (id)initWithDelegate:(id)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }
    [self subscribeToNotifications];
    return self;
}

- (void)recalculateContactLocationMidpointWithContacts:(NSArray *)contacts {
    // Calculate geographic midpoint between all contacts
    // Emit notification with midpoint location
    
    NSInteger count = contacts.count;
    
    double tX = 0, tY = 0, tZ = 0;
    double avgX = 0, avgY = 0, avgZ = 0;
    
    for (int i = 0; i < count; i++) {
        
        CENContact *contact = contacts[i];
        CLLocationCoordinate2D coordinate = contact.location.coordinate;
        double lat = coordinate.latitude;
        double lng = coordinate.longitude;
        // degrees to radians
        lat = DegToRad(lat);
        lng = DegToRad(lng);
        // radian to cartesian coordinates
        double cX = cos(lat) * cos(lng);
        double cY = cos(lat) * sin(lng);
        double cZ = sin(lat);
        // add to running total of cartesian axis positions
        tX += cX;
        tY += cY;
        tZ += cZ;
    }
    
    // average cartesian position
    avgX = tX/count;
    avgY = tY/count;
    avgZ = tZ/count;
    // cartesian to radians
    double lng = atan2(avgY, avgX);
    double hyp = sqrt((avgX * avgX) + (avgY * avgY));
    double lat = atan2(avgZ, hyp);
    // radians to degrees
    lat = RadToDeg(lat);
    lng = RadToDeg(lng);

    [self emitMidpointUpdatedWithLocation:CLLocationMake(lat,lng)];
}

#pragma mark - Notification Emmision

- (void)emitMidpointUpdatedWithLocation:(CLLocation *)location {
    [[NSNotificationCenter defaultCenter] postNotificationName:nCENMidpointUpdated
                                                        object:location];
}

#pragma mark - Notfication Subscription

- (void)subscribeToNotifications {
    [self subscribeToLocationUpdatedNotification];
    [self subscribeToGeocodeCompletedNotification];
    [self subscribeToContactsHaveChangedNotification];
    [self subscribeToContactRemovedNotification];
}

- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         
     }];
}

- (void)subscribeToGeocodeCompletedNotification {
    // When objects conforming to the CENGeoInformationProtocol have been
    // geocoded, check their class and see if they should be displayed.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENGeocodeCompleted
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object conformsToProtocol:@protocol(CENGeoInformationProtocol)]) {
             
             // Check object class and handle appropriately
             if ([object isKindOfClass:[CENContact class]]) {
                 [self.delegate addContactAnnotationForContact:object];
             }
             else if ([object isKindOfClass:[MKPlacemark class]]) {
                 [self.delegate addSearchResult:object];
             }
         }
     }];
}

- (void)subscribeToContactRemovedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENContactRemovedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[CENContact class]]) {
             [self.delegate removeContactAnnotationForContact:object];
         }
     }];
}

- (void)subscribeToContactsHaveChangedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENContactsHaveChangedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         // Check if object is array of contacts, then recalculate geographic
         // midpoint between all contacts
         if ([object isKindOfClass:[NSArray class]]) {
             if ([object[0] isKindOfClass:[CENContact class]]) {
                 [self recalculateContactLocationMidpointWithContacts:object];
             }
         }
         
     }];
}


@end
