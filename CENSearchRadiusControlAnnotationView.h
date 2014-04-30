//
//  CENSearchAreaHandleAnnotationView.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CENSearchRadiusControlAnnotationView : MKAnnotationView

extern NSString * const caCENSearchAreaHandleAnnotationReuseID;

@property (nonatomic, assign) CGPoint centerPoint;

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation andFrame:(CGRect)rect;



@end
