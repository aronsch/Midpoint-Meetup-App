//
//  CENContactAnnotaion.h
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@class CENContact;

@interface CENContactAnnotation : NSObject <MKAnnotation>

+ (instancetype)annotationForContact:(CENContact *)contact;

@property(readonly, strong, nonatomic) CENContact *contact;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;
@property(nonatomic, strong) UIImage *contactImage;

@end
