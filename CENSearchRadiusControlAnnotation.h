//
//  CENSearchRadiusControlAnnotation.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CENSearchRadiusControlAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationDistance currentSearchRadius;
@property (nonatomic, assign) BOOL hasBeenMoved;

+ (instancetype)annotationWithLocation:(CLLocation *)location;
-(id)initWithLocation:(CLLocation *)location;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(CLLocation *)annotationLocation;
- (void)setLocation:(CLLocation *)location;

@end
