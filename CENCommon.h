//
//  CENCommon.h
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CENCommon : NSObject

#pragma mark - Application Notification Constants

#pragma mark -Search Notification Constancts
extern NSString * const nCENSearchResultsAdded;
extern NSString * const nCENSearchZeroed;

#pragma mark -Location Manager Notification Constants
extern NSString * const nCENUserLocationUpdatedNotification;
extern NSString * const nCENGeocodeCompleted;
extern NSString * const nCENMidpointUpdated;
extern NSString * const nCENETAReturnedNotification;

#pragma mark -Contact Notification Constants
extern NSString * const nCENContactAddedNotification;
extern NSString * const nCENContactRemovedNotification;
extern NSString * const nCENContactModifiedNotification;

#pragma mark -Map Interaction Notifications
extern NSString * const nCENSearchResultSelectedNotification;
extern NSString * const nCENContactSelectedNotification;
extern NSString * const nCENSearchRadiusChangedNotification;

#pragma mark -Travel Info View Notifications
extern NSString * const nCENETARequestedNotification;

@end

#pragma mark - Macros

#pragma mark Application Defaults Macros

#define CENDefaultsFloatForKey(key) [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"AJS.Center"] objectForKey:(key)] floatValue]

#define CENDefaultSearchRadius CENDefaultsFloatForKey(@"Default Search Radius")
#define CENDefaultSearchBuffer CENDefaultsFloatForKey(@"Search Buffer")
#define CENDefaultRadiusDelta CENDefaultsFloatForKey(@"Radius Delta Triggering Search Update")
#define CENDefaultLocationDelta CENDefaultsFloatForKey(@"User Location Delta Triggering Update")

#define CENDefaultsArrayForKey(key) (NSArray *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"AJS.Center"] objectForKey:(key)]


#pragma mark Position Calculation Macros
