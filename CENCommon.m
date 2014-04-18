//
//  CENCommon.m
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENCommon.h"

@implementation CENCommon

#pragma mark Application Notification Constants Declaration

#pragma mark -Search Notification Constancts
NSString * const cnCENSearchResultsAdded = @"CENSearchResultsAdded";
NSString * const cnCENSearchZeroed = @"CENSearchZeroed";

#pragma mark -Location Manager Notification Constants
NSString * const cnCENUserLocationUpdatedNotification = @"CENUserLocationUpdated";
NSString * const cnCENGeocodeCompleted = @"CENGeocodeCompleted";
NSString * const cnCENMidpointUpdated = @"CENMidpointUpdated";
NSString * const cnCENETAReturnedNotification = @"CENETAReturnedNotification";

#pragma mark -Contact Notification Constants
NSString * const cnCENContactAddedNotification = @"CENContactAdded";
NSString * const cnCENContactRemovedNotification = @"CENContactRemoved";
NSString * const cnCENContactModifiedNotification = @"CENContactModified";
NSString * const cnCENContactsHaveChangedNotification = @"CENContactsHaveChanged";

#pragma mark -Map Interaction Notifications
NSString * const cnCENSearchResultSelectedNotification = @"CENSearchResultSelected";
NSString * const cnCENContactSelectedNotification = @"CENContactSelectedNotification";
NSString * const cnCENSearchRadiusChangedNotification = @"CENSearchRadiusChangedNotification";
NSString * const cnCENMapCameraMovedNotification = @"CENMapCameraMovedNotification";

#pragma mark -Travel Info View Notifications
NSString * const cnCENETARequestedNotification = @"CENETARequestedNotification";

#pragma mark -Contact Object Notification
NSString * const cnCENGeocodeRequestedNotification = @"CENGeocodeRequestedNotification";

@end
