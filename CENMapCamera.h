//
//  CENMapCamera.h
//  Center
//
//  Created by Aron Schneider on 4/17/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CENMapCamera : MKMapCamera

-(void)setPitch:(CGFloat)pitch;
-(void)setAltitude:(CLLocationDistance)altitude;
-(void)setHeading:(CLLocationDirection)heading;
-(void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate;

@end
