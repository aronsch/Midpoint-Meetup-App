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
    [self setDelegate:delegate];
    [self subscribeToNotifications];
    return self;
}

#pragma mark - Notification Emmision

- (void)emitMidpointUpdatedWithLocation:(CLLocation *)location {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENMidpointUpdated
                                                        object:location];
}

#pragma mark - Notfication Subscription

- (void)subscribeToNotifications {
    [self subscribeToLocationUpdatedNotification];
    [self subscribeToLocationAvailableNotification];
    [self subscribeToContactRemovedNotification];
}

- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         
     }];
}

- (void)subscribeToLocationAvailableNotification {
    // When objects conforming to the CENGeoInformationProtocol have been
    // geocoded, check their class and see if they should be displayed.
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENLocationAvailableNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         
         if ([object conformsToProtocol:@protocol(CENGeoInformationProtocol)]) {
             
             if ([object isKindOfClass:[CENContact class]]) {
                 [self.delegate addContactAnnotationForContact:object];
             }
             else if ([object isKindOfClass:[MKPlacemark class]]) {
                 [self.delegate addSearchResult:object];
             }
         }
         else {
             // Raise Protocol Exception
             [CENCommon exceptionObjectDoesNotConformToCENGeoInformationProtocol:notification.object];
         }
     }];
}

- (void)subscribeToContactRemovedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENContactRemovedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[CENContact class]]) {
             [self.delegate removeContactAnnotationForContact:object];
         }
         else {
             [CENCommon exceptionPayloadClassExpected:[CENContact class] forNotification:notification];
         }
     }];
}


@end
