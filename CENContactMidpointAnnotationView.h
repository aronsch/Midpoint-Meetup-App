//
//  CENContactMidpointAnnotationView.h
//  Center
//
//  Created by Aron Schneider on 4/20/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CENContactMidpointAnnotationView : MKAnnotationView

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation andFrame:(CGRect)rect;

- (void)setVisible:(BOOL)visible animate:(BOOL)animated;
- (void)setVisible:(BOOL)visible
           animate:(BOOL)animated
      withNewFrame:(CGRect)newFrame;

extern NSString * const caCENContactMidpointAnnotationReuseID;

@end
