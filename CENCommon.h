//
//  CENCommon.h
//  Center
//
//  Created by Aron Schneider on 4/13/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import Foundation;
@import MapKit;

@protocol CENGeoInformationProtocol <NSObject>
// Protocol indicating that an object can produce a string describing
// its location and can have a location property set.
-(NSString *)addressAsString;
-(void)setLocation:(CLLocation *)location;
-(CLLocation *)location;

@optional
// Optionally support more complete placemark object
-(void)setPlacemark:(CLPlacemark *)placemark;

@end


@interface CENCommon : NSObject

#pragma mark - Application Notification Constants

#pragma mark -Search Notification Constancts
extern NSString * const cnCENSearchResultsAdded;
extern NSString * const cnCENSearchZeroed;

#pragma mark -Location Manager Notification Constants
extern NSString * const cnCENUserLocationUpdatedNotification;
extern NSString * const cnCENLocationAvailableNotification;
extern NSString * const cnCENMidpointUpdated;
extern NSString * const cnCENETAReturnedNotification;

#pragma mark -Contact Notification Constants
extern NSString * const cnCENContactAddedNotification;
extern NSString * const cnCENContactRemovedNotification;
extern NSString * const cnCENContactModifiedNotification;
extern NSString * const cnCENContactsHaveChangedNotification;

#pragma mark -Map Interaction Notifications
extern NSString * const cnCENSearchResultSelectedNotification;
extern NSString * const cnCENContactSelectedNotification;
extern NSString * const cnCENSearchRadiusChangedNotification;
extern NSString * const cnCENSearchRadiusRectChangedNotification;
extern NSString * const cnCENMapRegionWillChangeNotification;
extern NSString * const cnCENMapRegionDidChangeNotification;

#pragma mark -Travel Info View Notifications
extern NSString * const cnCENETARequestedNotification;

#pragma mark -CENGeoInformationProtocol Notification
extern NSString * const cnCENGeocodeRequestedNotification;

#pragma mark - Standard Exceptions
+(void)exceptionObjectDoesNotConformToCENGeoInformationProtocol:(id)object;
+(void)exceptionClassExpected:(Class)expectedClass
      forNotification:(NSNotification *)notification;

#pragma - Standard Colors
+ (UIColor *)blueFillColor;
+ (UIColor *)blueFillColorLowAlpha;
+ (UIColor *)blueBorderColor;
+ (UIColor *)blueBorderColorLowAlpha;
+ (UIColor *)shadowColor;

#pragma mark - NSValue Encoding

+ (NSValue *)valueWithMapRect:(MKMapRect)mapRect;
+ (MKMapRect)mapRectFromValue:(NSValue *)mapRectValue;

@end

#pragma - Standard Geometry Functions

CGPoint RectGetCenter( CGRect rect);
CGRect RectAroundCenter( CGPoint center, CGSize size);
CGRect RectCenteredInRect( CGRect rect, CGRect mainRect);
CGSize sizeForSquareThatFitsRect(CGRect rect);
CGFloat distanceBetweenPoints (CGPoint a, CGPoint b);

#pragma - Map Geometry Functions

MKMapRect MKMapRectForCoordinateRegion(MKCoordinateRegion region);

#pragma mark - Macros

#pragma mark Application Defaults Macros

#define CENDefaultsFloatForKey(key) [[[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"AJS.Center"] objectForKey:(key)] floatValue]

#define CENDefaultSearchRadius  CENDefaultsFloatForKey(@"Default Search Radius")
#define CENDefaultSearchBuffer  CENDefaultsFloatForKey(@"Search Buffer")
#define CENDefaultRadiusDelta   CENDefaultsFloatForKey(@"Radius Delta Triggering Search Update")
#define CENDefaultLocationDelta CENDefaultsFloatForKey(@"User Location Delta Triggering Update")

#define CENDefaultsArrayForKey(key) (NSArray *)[[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"AJS.Center"] objectForKey:(key)]

#define CENPlaceTypesArray CENDefaultsArrayForKey(@"Place Types List")

#pragma mark Position Calculation Macros

#define DegToRad(deg) deg * (M_PI/180)
#define RadToDeg(rad) rad * (180/M_PI)

#pragma mark Location Macros

#define CLLocationMake(lat,lng) [[CLLocation alloc] initWithLatitude:(lat) longitude:(lng)]

#define CLLocationWithCLLocationCoordinate2D(coordinate) [[CLLocation alloc] initWithLatitude:(coordinate).latitude longitude:(coordinate).longitude]

#define CLLocationCoordinate2DWithLocation(location) CLLocationCoordinate2DMake((location).coordinate.latitude, (location).coordinate.longitude)


#pragma mark - DEBUG

#define NSLogRect(rect, loglabel) NSLog(@"%@ rect \r xOrig: %f \r yOrig: %f \r width: %f \r height: %f ", (loglabel), (rect).origin.x, (rect).origin.y, (rect).size.width, (rect).size.height);

void CENLogRect (CGRect rect, NSString *name);
void CENLogMapRect (MKMapRect mapRect, NSString *name);
void CENLogCoordinate (CLLocationCoordinate2D coordinate, NSString *name);
void CENLogPoint (CGPoint point, NSString *name);



