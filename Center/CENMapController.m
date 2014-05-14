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
#import "CENSearchResult.h"
#import <MapKit/MapKit.h>

@interface CENMapController ()

@property (nonatomic) id delegate;
@property (nonatomic) NSMutableSet *searchResults;

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
    [self subscribeToNewSearchResultsNotification];
    [self subscribeToSearchZeroedNotification];
}

- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         // TODO - Necessary?
     }];
}


- (void)subscribeToNewSearchResultsNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENSearchResultsAdded
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[NSSet class]]) {
             [self.searchResults unionSet:object];
             [self.delegate addSearchResults:object];
         }
         else {
             [CENCommon exceptionPayloadClassExpected:[NSSet class] forNotification:notification];
         }
     }];
}

- (void)subscribeToSearchZeroedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENSearchZeroed
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         [self.delegate removeAllSearchResults];
         [self.searchResults removeAllObjects];
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
