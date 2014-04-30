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
NSString * const cnCENLocationAvailableNotification = @"CENGeocodeCompleted";
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
NSString * const cnCENSearchRadiusRectChangedNotification = @"CENSearchRadiusrectChangedNotification";
NSString * const cnCENMapRegionWillChangeNotification = @"CENMapRegionWillChangeNotification";
NSString * const cnCENMapRegionDidChangeNotification = @"CENMapRegionDidChangeNotification";

#pragma mark -Travel Info View Notifications
NSString * const cnCENETARequestedNotification = @"CENETARequestedNotification";

#pragma mark -Contact Object Notification
NSString * const cnCENGeocodeRequestedNotification = @"CENGeocodeRequestedNotification";


#pragma mark - Standard Exceptions

+(void)exceptionObjectDoesNotConformToCENGeoInformationProtocol:(id)object {
    [NSException raise:@"Object Does Not Conform to CENGeoInformation Protocol"
                format:@"Listener for %@ expected object conforming to CENGeoInformation protocol with notification. Recieved %@ instead.", cnCENLocationAvailableNotification, NSStringFromClass([object class])];
}

+(void)exceptionClassExpected:(Class)expectedClass
              forNotification:(NSNotification *)notification {
    NSString *raiseMessage = [NSString stringWithFormat:@"Listener Expected %@ Object",NSStringFromClass(expectedClass)];
    [NSException raise:raiseMessage
                format:@"Listener for %@ expected %@ object as part of notification; recieved %@ instead.",
                         notification.name,
                         NSStringFromClass([notification.object class]),
                         NSStringFromClass(expectedClass)];
}

#pragma Standard Geometry Functions

CGPoint RectGetCenter( CGRect rect) {
    return CGPointMake( CGRectGetMidX( rect), CGRectGetMidY( rect));
}

CGRect RectAroundCenter(CGPoint center, CGSize size) {
    CGFloat halfWidth = size.width / 2.0f;
    CGFloat halfHeight = size.height / 2.0f;
    return CGRectMake( center.x - halfWidth, center.y - halfHeight, size.width, size.height);
}

CGRect RectCenteredInRect( CGRect rect, CGRect mainRect) {
    CGFloat dx = CGRectGetMidX( mainRect) - CGRectGetMidX( rect);
    CGFloat dy = CGRectGetMidY( mainRect) - CGRectGetMidY( rect);
    return CGRectOffset( rect, dx, dy);
}

#pragma Map Geometry Functions

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region)
{
    MKMapPoint a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude + region.span.latitudeDelta / 2,
                                                                      region.center.longitude - region.span.longitudeDelta / 2));
    MKMapPoint b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                                                                      region.center.latitude - region.span.latitudeDelta / 2,
                                                                      region.center.longitude + region.span.longitudeDelta / 2));
    return MKMapRectMake(MIN(a.x,b.x), MIN(a.y,b.y), ABS(a.x-b.x), ABS(a.y-b.y));
}


@end
