//
//  CENContactMidpointOverlayRenderer.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CENContactMidpointOverlayRenderer : MKOverlayRenderer

+(instancetype)withOverlay:(id<MKOverlay>)overlay;

/**
 @param overlay The overlay corresponding to this view.
 @param mapRects an array of NSValue-encoded MKMapRects that will be used to draw overlapping ellipses onto the overlay.
 */
+(instancetype)withOverlay:(id<MKOverlay>)overlay
           andOverlapRects:(NSArray *)mapRects;

-(void)setContactOverlapMapRects:(NSArray *)overlapRects;

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context;

@end
