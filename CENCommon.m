//
//  CENCommon.m
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENCommon.h"
@class CLLocation;

@implementation CENCommon

#pragma mark Application Notification Constants Declaration

#pragma mark -Search Notification Constancts
NSString * const nCENSearchResultsAdded = @"CENSearchResultsAdded";
NSString * const nCENSearchZeroed = @"CENSearchZeroed";

#pragma mark -Location Manager Notification Constants
NSString * const nCENUserLocationUpdatedNotification = @"CENUserLocationUpdated";
NSString * const nCENGeocodeCompleted = @"CENGeocodeCompleted";
NSString * const nCENMidpointUpdated = @"CENMidpointUpdated";
NSString * const nCENETAReturnedNotification = @"CENETAReturnedNotification";

#pragma mark -Contact Notification Constants
NSString * const nCENContactAddedNotification = @"CENContactAdded";
NSString * const nCENContactRemovedNotification = @"CENContactRemoved";
NSString * const nCENContactModifiedNotification = @"CENContactModified";

#pragma mark -Map Interaction Notifications
NSString * const nCENSearchResultSelectedNotification = @"CENSearchResultSelected";
NSString * const nCENContactSelectedNotification = @"CENContactSelectedNotification";
NSString * const nCENSearchRadiusChangedNotification = @"CENSearchRadiusChangedNotification";

#pragma mark -Travel Info View Notifications
NSString * const nCENETARequestedNotification = @"CENETARequestedNotification";

#pragma mark -Contact Object Notification
NSString * const nCENGeocodeRequestedNotification = @"CENGeocodeRequestedNotification";

@end
