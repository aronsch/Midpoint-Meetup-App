//
//  CENCommon.m
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENCommon.h"

@implementation CENCommon

#pragma mark - Application Notification Constants Declaration

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


#pragma mark - Map Geometry Functions

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

#pragma mark - Standard Colors

+ (UIColor *)blueFillColor {
    return [UIColor colorWithRed:0.114 green:0.705 blue:1 alpha:1];
}

+ (UIColor *)blueFillColorLowAlpha {
    return [UIColor colorWithRed:0.114 green:0.705 blue:1 alpha:0.1];
}

+ (UIColor *)blueBorderColor {
    return [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:1];
}

+ (UIColor *)blueBorderColorLowAlpha {
    return [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:0.85];
}

+ (UIColor *)shadowColor {
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
}

#pragma mark - NSValue Encoding

+ (NSValue *)valueWithMapRect:(MKMapRect)mapRect {
    return [NSValue value:&mapRect withObjCType:@encode(MKMapRect)];
}

+ (MKMapRect)mapRectFromValue:(NSValue *)mapRectValue {
    MKMapRect mapRect;
    [mapRectValue getValue:&mapRect];
    return mapRect;
}

@end

#pragma mark - Standard Geometry Functions

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

CGSize sizeForSquareThatFitsRect(CGRect rect) {
    CGFloat size = MIN(rect.size.height, rect.size.width);
    return CGSizeMake(size, size);
}

CGFloat distanceBetweenPoints (CGPoint a, CGPoint b) {
    return sqrt(pow(a.x - b.x,2) + pow(a.y - b.y, 2));
}


#pragma mark - Debug Logging

void CENLogRect (CGRect rect, NSString *name) {
    NSLog(@"%@ rect \r origin { x: %f, y: %f }, size { width: %f, height: %f }", name, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

void CENLogMapRect (MKMapRect mapRect, NSString *name) {
    NSLog(@"%@ rect { origin.x: %f, origin.y: %f, width: %f, height: %f }", name, mapRect.origin.x, mapRect.origin.y, mapRect.size.width, mapRect.size.height);
}

void CENLogCoordinate (CLLocationCoordinate2D coordinate, NSString *name) {
    NSLog(@"%@ coordinate { lat: %f, lng: %f }" , name, coordinate.latitude, coordinate.longitude);
}

void CENLogPoint (CGPoint point, NSString *name) {
    NSLog(@"%@ CGPoint - { x: %f, y: %f",name,point.x,point.y);
}





