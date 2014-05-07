//
//  CENContactMidpointAnnotationView.m
//  Center
//
//  Created by Aron Schneider on 4/20/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactMidpointAnnotationView.h"
#import "CENContactsMidpointAnnotation.h"
#import "CENCommon.h"
#import <QuartzCore/QuartzCore.h>

@interface CENContactMidpointAnnotationView ()

@property (strong, nonatomic) CALayer *searchRadiusCircleLayer;
@property (strong, nonatomic) CAShapeLayer *circleLower;
@property (strong, nonatomic) CAShapeLayer *circleUpper;

@property (nonatomic, assign) BOOL visible;

@end

@implementation CENContactMidpointAnnotationView

NSString * const caCENContactMidpointAnnotationReuseID = @"CENContactMidpointAnnotation";

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation andFrame:(CGRect)frame {
    return [[CENContactMidpointAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:caCENContactMidpointAnnotationReuseID andFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:CGRectMake(0, 0, 30, 30)];
    }
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
               andFrame:(CGRect)frame {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFrame:frame];
        [self setOpaque:NO];
        [self setClipsToBounds:NO];
        [self setUserInteractionEnabled:NO];
        [self setDraggable:NO];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (!self.searchRadiusCircleLayer) {
        [self.layer addSublayer:[self contentsLayerWithRect:rect]];
    }
    else {
        [self updateCirclePathsWithRect:rect];
    }
}

#pragma mark - Animation Generators

#define TransitionDuration 0.15f

- (CABasicAnimation *)pathUpdateAnimationToRect:(CGRect)rect fromRect:(CGRect)oldRect {
    CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
    [pathAnim setFromValue:(id)[UIBezierPath bezierPathWithOvalInRect:oldRect].CGPath];
    [pathAnim setToValue:(id)[UIBezierPath bezierPathWithOvalInRect:rect].CGPath];
    [pathAnim setRemovedOnCompletion:NO];
    [pathAnim setFillMode:kCAFillModeForwards];
    [pathAnim setDuration:TransitionDuration];
    return pathAnim;
}

#pragma mark - View Control

-(void)hideWithAnimation:(BOOL)animated {
    NSTimeInterval duration = animated ? TransitionDuration : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.layer setOpacity:0];
                     }
                     completion:^(BOOL finished) {
                         [self setHidden:YES];
                     }];
}

- (void)setVisible:(BOOL)visible animate:(BOOL)animated {
    [self setVisible:visible animate:animated withNewFrame:CGRectNull];
}

- (void)setVisible:(BOOL)visible animate:(BOOL)animated withNewFrame:(CGRect)newFrame {
    BOOL wasVisible = _visible;
    _visible = visible;
    if (visible && !wasVisible && CGRectIsNull(newFrame)) {
        [self showWithAnimation:animated];
    }
    else if (visible && !wasVisible && !CGRectIsNull(newFrame)) {
        [self showWithAnimation:animated withNewFrame:newFrame];
    }
    else if (visible && wasVisible && !CGRectIsNull(newFrame)) {
        [self showWithAnimation:animated withNewFrame:newFrame];
    }
    else if (!visible && wasVisible) {
        [self hideWithAnimation:animated];
    }
}

-(void)showWithAnimation:(BOOL)animated {
    [self setHidden:NO];
    NSTimeInterval duration = animated ? TransitionDuration : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.layer setOpacity:1];
                     }];
}

-(void)showWithAnimation:(BOOL)animated withNewFrame:(CGRect)newFrame {
    [self setFrame:newFrame];
    [self setHidden:NO];
    [self setNeedsDisplay];
    NSTimeInterval duration = animated ? TransitionDuration : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.layer setOpacity:1];
                     }];
}

- (void)updateCirclePathsWithRect:(CGRect)rect {
    CGPathRef newPath = [self searchAreaCirclePathForRect:rect];
    [self.circleLower setPath:newPath];
    [self.circleUpper setPath:newPath];
}

- (CGPathRef)searchAreaCirclePathForRect:(CGRect)rect {
    rect = RectAroundCenter(RectGetCenter(rect), CGSizeMake(rect.size.width-5, rect.size.height-5));
    rect = CGRectIntegral(rect);
    
    return [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
}

- (CALayer *)contentsLayerWithRect:(CGRect)rect {
    CGPathRef circlePath = [self searchAreaCirclePathForRect:rect];
    
    CAShapeLayer *lowerCircle = [CAShapeLayer layer];
    lowerCircle.path = circlePath;
    [lowerCircle setFillColor:[UIColor clearColor].CGColor];
    [lowerCircle setStrokeColor:[CENCommon blueBorderColor].CGColor];
    [lowerCircle setLineWidth:5];
    [lowerCircle setShadowColor:[UIColor blackColor].CGColor];
    [lowerCircle setShadowOffset:CGSizeMake(1.1, 1.1)];
    [lowerCircle setShadowRadius:2];
    [lowerCircle setShadowOpacity:0.25];
    
    CAShapeLayer *upperCircle = [CAShapeLayer layer];
    upperCircle.path = circlePath;
    [upperCircle setFillColor:[UIColor clearColor].CGColor];
    [upperCircle setStrokeColor:[CENCommon blueFillColor].CGColor];
    [upperCircle setLineWidth:3];
    
    CALayer *combinedLayer = [CALayer layer];
    [combinedLayer addSublayer:lowerCircle];
    [combinedLayer addSublayer:upperCircle];
    
    [self setCircleLower:lowerCircle];
    [self setCircleUpper:upperCircle];
    [self setSearchRadiusCircleLayer:combinedLayer];
    
    return combinedLayer;
}

/*- (CALayer *)contentsLayerWithRect:(CGRect)rect {
    
    rect = RectAroundCenter(RectGetCenter(rect), CGSizeMake(rect.size.width-5, rect.size.height-5));
    
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color = [UIColor colorWithRed:0.114 green:0.705 blue:1 alpha:1];
    UIColor* color2 = [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:1];
    
    //// Shadow
    UIColor* shadow3 = [[UIColor blackColor] colorWithAlphaComponent:0.34];
    CGSize shadow3Offset = CGSizeMake(1.1, 1.1);
    CGFloat shadow3BlurRadius = 2;
    
    {
    
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow3Offset, shadow3BlurRadius, shadow3.CGColor);
        CGContextBeginTransparencyLayer(context, NULL);
        
        // Lower
        UIBezierPath* oval2Path = [UIBezierPath bezierPathWithOvalInRect:rect];
        [color2 setStroke];
        oval2Path.lineWidth = 5;
        [oval2Path stroke];
        
        // Oval Drawing
        [color setStroke];
        oval2Path.lineWidth = 3;
        [oval2Path stroke];
        
        CGContextEndTransparencyLayer(context);
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CALayer *layer = [CALayer layer];
    [layer setContents:image];
    return layer;
    
}*/


@end
