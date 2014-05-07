//
//  CENSearchRadiusControlAnnotationView
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import UIKit;
@import MapKit;
@class CENViewController;

@class CENSearchRadiusControlAnnotation;

@interface CENSearchRadiusControlAnnotationView : MKAnnotationView

@property (nonatomic,assign) MKAnnotationViewDragState dragState;

extern NSString * const caCENSearchAreaHandleAnnotationReuseID;


+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation
                     andCenter:(CGPoint)center;

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation
                    andCenter:(CGPoint)center
                   forViewController:(CENViewController *)vc;

- (CENSearchRadiusControlAnnotation *)controlAnnotation;
- (void)startDragAnimation;
- (void)endDragAnimation;
- (void)updateWithTouchPoint:(CGPoint)point andOverlapPoint:(CGPoint)overlapPoint;


@end
