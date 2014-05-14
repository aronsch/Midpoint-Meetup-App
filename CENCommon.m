//
//  CENCommon.m
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENCommon.h"

@implementation CENCommon

#pragma mark - Application Notification Constants

#pragma mark Search Notification Constancts
NSString * const cnCENSearchResultsAdded = @"CENSearchResultsAdded";
NSString * const cnCENSearchZeroed = @"CENSearchZeroed";

#pragma mark Location Manager Notification Constants
NSString * const cnCENUserLocationUpdatedNotification = @"CENUserLocationUpdated";
NSString * const cnCENMidpointUpdated = @"CENMidpointUpdated";
NSString * const cnCENETAReturnedNotification = @"CENETAReturnedNotification";

#pragma mark Contact Notification Constants
NSString * const cnCENContactAddedNotification = @"CENContactAdded";
NSString * const cnCENContactRemovedNotification = @"CENContactRemoved";
NSString * const cnCENContactModifiedNotification = @"CENContactModified";
NSString * const cnCENContactsHaveChangedNotification = @"CENContactsHaveChanged";

#pragma mark Map Interaction Notifications
NSString * const cnCENSearchResultSelectedNotification = @"CENSearchResultSelected";
NSString * const cnCENContactSelectedNotification = @"CENContactSelectedNotification";
NSString * const cnCENSearchRadiusChangedNotification = @"CENSearchRadiusChangedNotification";
NSString * const cnCENSearchRegionChangedNotification = @"CENSearchRegionChangedNotification";
NSString * const cnCENMapRegionWillChangeNotification = @"CENMapRegionWillChangeNotification";
NSString * const cnCENMapRegionDidChangeNotification = @"CENMapRegionDidChangeNotification";
NSString * const cnCENDismissSearchViewNotification = @"CENDismissSearchViewNotification";

#pragma mark Travel Info View Notifications
NSString * const cnCENETARequestedNotification = @"CENETARequestedNotification";
NSString * const cnCENETANeededForResultNotification = @"CENETANeededForResultNotification";
NSString * const cnCENETAReturnedForContactNotification = @"CENETAReturnedForContactNotification";

#pragma mark CENGeoInformationProtocol Notifications
NSString * const cnCENGeocodeRequestedNotification = @"CENGeocodeRequestedNotification";
NSString * const cnCENLocationAvailableNotification = @"CENGeocodeCompleted";

#pragma mark Contact Object Notifications
NSString * const cnCENContactUpdateRequestedNotification = @"CENContactUpdateRequestedNotification";

#pragma mark - Standard Notification Emission

+(void)emitDismissSearchViewNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENDismissSearchViewNotification object:nil];
}

#pragma mark - ETA Dictionary Key Constants
NSString * const kCENETASourceKey = @"CENETASource";
NSString * const kCENETADestinationKey = @"CENETADestination";
NSString * const kCENETAETATimeKey = @"CENETATime";

#pragma mark - Standard Exceptions

+(void)exceptionObjectDoesNotConformToCENGeoInformationProtocol:(id)object {
    [NSException raise:@"Object Does Not Conform to CENGeoInformation Protocol"
                format:@"Listener for %@ expected object conforming to CENGeoInformation protocol with notification. Recieved %@ instead.", cnCENLocationAvailableNotification, NSStringFromClass([object class])];
}

+(void)exceptionPayloadClassExpected:(Class)expectedClass
              forNotification:(NSNotification *)notification {
    NSString *raiseMessage = [NSString stringWithFormat:@"Listener Expected %@ Object",NSStringFromClass(expectedClass)];
    [NSException raise:raiseMessage
                format:@"Listener for %@ expected %@ object as payload; recieved %@ instead.",
                         notification.name,
                         NSStringFromClass([notification.object class]),
                         NSStringFromClass(expectedClass)];
}



#pragma mark - Standard Colors

+ (UIColor *)blueFillColor {
    // 30,180,255
    return [UIColor colorWithRed:0.114f green:0.705f blue:1.0f alpha:1.0f];
}

+ (UIColor *)orangeComplementFillColor {
    return [UIColor colorWithRed:255/255.0f green:145/255.0f blue:18/255.0f alpha:1.0f];
}

+ (UIColor *)orangeComplementBorderColor {
    return [UIColor colorWithRed:239/255.0f green:128/255.0f blue:0 alpha:1.0f];
}

+ (UIColor *)blueFillColorLowAlpha {
    return [UIColor colorWithRed:0.114f green:0.705f blue:1.0f alpha:0.1f];
}

+ (UIColor *)blueBorderColor {
    return [UIColor colorWithRed:0 green:0.59f blue:0.886f alpha:1.0f];
}

+ (UIColor *)blueBorderColorLowAlpha {
    return [UIColor colorWithRed:0 green:0.59f blue:0.886f alpha:0.85f];
}

+ (UIColor *)shadowColor {
    return [[UIColor blackColor] colorWithAlphaComponent:0.25];
}

+(UIColor *)distantShadowColor {
    return [[UIColor blackColor] colorWithAlphaComponent:0.15f];
}

#pragma mark - Shadows Parameters

+ (CGSize)lowShadowSize {
    return CGSizeMake(0, 2);
}

+ (CGFloat)lowShadowBlur {
    return 2.0f;
}

+ (CGSize)midShadowSize {
    return CGSizeMake(0, 5);
}

+ (CGFloat)midShadowBlur {
    return 4.0f;
}

+ (CGSize)highShadowSize {
    return CGSizeMake(0, 9);
}

+ (CGFloat)highShadowBlur {
    return 10.0f;
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

+(NSValue *)valueWithRegion:(MKCoordinateRegion)region {
    return [NSValue value:&region withObjCType:@encode(MKCoordinateRegion)];
}

+(MKCoordinateRegion)regionFromValue:(NSValue *)regionValue {
    MKCoordinateRegion region;
    [regionValue getValue:&region];
    return region;
}

+(NSValue *)valueWithColorRef:(CGColorRef)color {
    return [NSValue value:&color withObjCType:@encode(CGColorRef)];
}

+(NSValue *)valueWithTimeInterval:(NSTimeInterval)t {
    return [NSValue value:&t withObjCType:@encode(NSTimeInterval)];
} 

+(NSTimeInterval)timeIntervalForValue:(NSValue *)value {
    NSTimeInterval t;
    [value getValue:&t];
    return t;
}

#pragma mark - Dictionary Factories
+(NSDictionary *)etaRequestDictionionaryWithSource:(id<CENETAInformationProtocol>)source
                                    andDestination:(id<CENETAInformationProtocol>)destination {
    return @{kCENETASourceKey: source,
             kCENETADestinationKey: destination,
             kCENETAETATimeKey: [NSNull null]};
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
    return (CGFloat)sqrtf(powf((float)a.x - (float)b.x,2.0f) + powf((float)a.y - (float)b.y, 2.0f));
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





