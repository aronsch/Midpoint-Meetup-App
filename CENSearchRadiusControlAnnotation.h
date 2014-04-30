//
//  CENSearchAreaAnnotation.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CENSearchRadiusControlAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationDistance currentSearchRadius;

+ (instancetype)annotationWithLocation:(CLLocation *)location;
-(id)initWithLocation:(CLLocation *)location;

-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(CLLocation *)annotationLocation;
- (void)setLocation:(CLLocation *)location;

@end
