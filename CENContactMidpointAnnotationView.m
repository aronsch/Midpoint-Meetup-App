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

@property (strong, nonatomic) CAShapeLayer *searchRadiusCircle;
@property (strong, nonatomic) CAShapeLayer *searchRadiusSliderCircle;
@property (strong, nonatomic) CAShapeLayer *leaderLine;
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
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
//    NSLogRect(rect, @"current MPAV frame");
//    // Update Search Area Circle Or Draw If None
//    if (self.searchRadiusCircle) {
//        [self.searchRadiusCircle setPath:[self searchAreaCirclePathWithRect:rect]];
//    }
//    else {
//        [self setSearchRadiusCircle:[self searchAreaCircleWithRect:rect]];
//        [self.layer addSublayer:self.searchRadiusCircle];
//    }
//    
//    // Update Search Radius Slider Handle Or Draw If None
//    if (self.searchRadiusSliderCircle) {
//        [self.searchRadiusSliderCircle setPath:[self radiusSliderButtonPath]];
//    }
//    else {
//        [self setSearchRadiusSliderCircle:[self radiusSliderButton]];
//        [self.layer addSublayer:self.searchRadiusSliderCircle];
//    }
//    
//    // Update Search Area Circle Or Draw If None
//    if (self.leaderLine) {
//        [self.leaderLine setPath:[self leaderLinePath]];
//    }
//    else {
//        [self setLeaderLine:[self leaderLineShape]];
//        [self.layer addSublayer:self.leaderLine];
//    }
    [self.layer addSublayer:[self contentsLayerWithRect:rect]];
}

-(CAShapeLayer *)searchAreaCircleWithRect:(CGRect)rect {
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [self searchAreaCirclePathWithRect:rect];
    [circle setFillColor:[[UIColor colorWithRed:0 green:0.1 blue:0.8 alpha:0.11] CGColor]];
    [circle setStrokeColor:[[UIColor colorWithRed:0 green:0.1 blue:0.8 alpha:1.0] CGColor]];
    [circle setLineWidth:2.0];
    [circle setOpaque:NO];
    return circle;
}

-(CAShapeLayer *)radiusSliderButton {

    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [self radiusSliderButtonPath];
    [circle setFillColor:[[UIColor colorWithRed:232.0/255 green:80.0/255 blue:80.0/255 alpha:0.5] CGColor]];
    [circle setStrokeColor:[[UIColor colorWithRed:232.0/255 green:80.0/255 blue:80.0/255 alpha:1.0] CGColor]];
    [circle setLineWidth:3.0];
    [circle setOpaque:NO];
    return circle;
}

-(CAShapeLayer *)leaderLineShape {
    
    CAShapeLayer *line = [CAShapeLayer layer];
    line.path = [self leaderLinePath];
    [line setLineWidth:3.0];
    line.strokeColor = [[UIColor colorWithRed:232.0/255
                                        green:80.0/255
                                         blue:80.0/255
                                        alpha:1.0] CGColor];
    [line setLineDashPattern:@[@5,@2]];
    return line;
}

-(CGMutablePathRef)leaderLinePath {
    CGMutablePathRef linePath = CGPathCreateMutable();
    NSLog(@"rectCenter: x: %f, y: %f",
          CGRectGetMidX(self.searchRadiusSliderCircle.frame),
          CGRectGetMidY(self.searchRadiusSliderCircle.frame));
    CGPathMoveToPoint(linePath,
                      NULL,
                      CGRectGetMidX(self.frame),
                      CGRectGetMidY(self.frame));
    CGPathAddLineToPoint(linePath,
                         NULL,
                         CGRectGetMidX(CGPathGetBoundingBox(self.searchRadiusSliderCircle.path))-16,
                         CGRectGetMidY(CGPathGetBoundingBox(self.searchRadiusSliderCircle.path))-16);
    return linePath;
}

-(CGPathRef)searchAreaCirclePathWithRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    return path.CGPath;
}

-(CGPathRef)radiusSliderButtonPath {
    CGFloat currentSize = 44;
    CGFloat xOrigin = CGRectGetMaxX(self.frame)-15;
    CGFloat yOrigin = CGRectGetMaxY(self.frame)-15;
    CGRect newSBRect = CGRectMake(xOrigin, yOrigin, currentSize, currentSize);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:newSBRect];
    
    return path.CGPath;
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
    else if (!visible) {
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
    
    NSTimeInterval duration = animated ? TransitionDuration : 0;
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.layer setOpacity:1];
                     }];
}



- (CALayer *)contentsLayerWithRect:(CGRect)rect {
    
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
    
}



@end
