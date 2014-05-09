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

@property (strong,nonatomic) NSArray *contactOverlapMapRects;

@end

@implementation CENContactMidpointOverlayRenderer

+(instancetype)withOverlay:(id<MKOverlay>)overlay {
    return [[CENContactMidpointOverlayRenderer alloc] initWithOverlay:overlay];
}

+(instancetype)withOverlay:(id<MKOverlay>)overlay andOverlapRects:(NSArray *)mapRects {
    return [[CENContactMidpointOverlayRenderer alloc] initWithOverlay:overlay andOverlapRects:mapRects];
}

-(id)initWithOverlay:(id<MKOverlay>)overlay {
    self = [super initWithOverlay:overlay];
    if (!self) {
        return nil;
    }
    return self;
}

-(id)initWithOverlay:(id<MKOverlay>)overlay andOverlapRects:(NSArray *)mapRects;{
    self = [super initWithOverlay:overlay];
    if (!self) {
        return nil;
    }
    [self setContactOverlapMapRects:mapRects];
    return self;
}


#pragma mark - Drawing

-(void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
    
    CGContextSetStrokeColorWithColor(context, [[CENCommon orangeComplementFillColor] colorWithAlphaComponent:0.75].CGColor);
    CGContextSetFillColorWithColor(context, [[CENCommon orangeComplementFillColor] colorWithAlphaComponent:0.01].CGColor);
    NSLog(@"zoomScale %f",zoomScale);
    CGContextSetLineWidth(context, 2/zoomScale);
    
    for (NSValue *value in self.contactOverlapMapRects) {
        MKMapRect overlapMapRect = [CENCommon mapRectFromValue:value];
        CGRect rect = [self rectForMapRect:overlapMapRect];
        CGContextFillEllipseInRect(context, rect);
        CGContextStrokeEllipseInRect(context, rect);
    }
    
}

# pragma mark - Setters

-(void)setContactOverlapMapRects:(NSArray *)overlapRects {
    _contactOverlapMapRects = overlapRects;
    [self setNeedsDisplay];
}

@end
