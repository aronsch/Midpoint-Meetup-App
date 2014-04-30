//
//  CENContactMidpointOverlayRenderer.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactMidpointOverlayRenderer.h"
#import "CENCommon.h"

@interface CENContactMidpointOverlayRenderer ()

@property (nonatomic, assign) MKMapSize searchRadius;

@end

@implementation CENContactMidpointOverlayRenderer

+(instancetype)withOverlay:(id<MKOverlay>)overlay {
    return [[CENContactMidpointOverlayRenderer alloc] initWithOverlay:overlay];
}

-(id)initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (!self) {
        return nil;
    }
    return self;
}

#pragma mark - Drawing

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
}

@end
