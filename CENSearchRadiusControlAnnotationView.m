//
//  CENSearchRadiusControlAnnotationView.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//
 
#import "CENSearchRadiusControlAnnotationView.h"
#import "CENSearchRadiusControlAnnotation.h"
#import "CENCommon.h"
#import "CENViewController.h"

@interface CENSearchRadiusControlAnnotationView ()

@property (nonatomic) CAShapeLayer *searchRadiusSliderCircle;
@property (nonatomic) CAShapeLayer *leaderLine;
@property (nonatomic) CAShapeLayer *centerMarker;
@property (nonatomic, assign) CGFloat handleOffset;
@property (nonatomic) CENViewController *viewController;
@property (nonatomic) CGFloat currentScale;

@end

@implementation CENSearchRadiusControlAnnotationView


NSString * const caCENSearchAreaHandleAnnotationReuseID = @"CENSearchAreaHandleAnnotationView";

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation  andCenter:(CGPoint)center {
    return [[CENSearchRadiusControlAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:caCENSearchAreaHandleAnnotationReuseID
                                                                 andCenter:(CGPoint)center];
}

+(instancetype)withAnnotation:(id<MKAnnotation>)annotation andCenter:(CGPoint)center forViewController:(CENViewController *)vc  {
    return [[CENSearchRadiusControlAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:caCENSearchAreaHandleAnnotationReuseID
                                                                   andCenter:center
                                                                  andViewController:vc];
}

-(instancetype)initWithAnnotation:(id<MKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
                andCenter:(CGPoint)center {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFrame:RectAroundCenter(center, CGSizeMake(50, 50))];
        [self setOpaque:NO];
        [self setDraggable:YES];
    }
    return self;
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
              andCenter:(CGPoint)center
             andViewController:(CENViewController *)vc {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = RectAroundCenter(center, CGSizeMake(50, 50));
        self.opaque = NO;
        self.draggable = YES;
        self.viewController = vc;
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (frame.size.height < 44 || frame.size.width < 44 ) {
            CGFloat oldSize = MIN(frame.size.height, frame.size.width);
            CGFloat newSizeDelta = 50 - oldSize;
            frame = CGRectInset(frame, -newSizeDelta, -newSizeDelta);
        }
        self.frame = frame;
        self.exclusiveTouch = YES;
        self.currentScale = 1.0f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    // Update Search Radius Slider Handle Or Draw If None
    if (self.searchRadiusSliderCircle) {
        [self.searchRadiusSliderCircle setPath:[self radiusSliderButtonPathForRect:rect]];
    }
    else {
        [self setSearchRadiusSliderCircle:[self makeRadiusSliderButtonForRect:rect]];
        [self.layer addSublayer:self.searchRadiusSliderCircle];
    }
    
    // Update Leaderline or draw if none;
    if (!self.leaderLine) {
        [self setLeaderLine:[self makeLeaderLineShape]];
        self.leaderLine.frame = self.viewController.view.frame;
        self.leaderLine.zPosition = -1;
        [self.layer addSublayer:self.leaderLine];
    }
    if (!self.centerMarker) {
        [self setCenterMarker:[self makeCenterMarkerShape]];
        [self.layer addSublayer:self.centerMarker];
    }
    
}

#pragma mark - CAShapeLayer Generators

-(CAShapeLayer *)makeRadiusSliderButtonForRect:(CGRect)rect {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self radiusSliderButtonPathForRect:rect];
    
    UIColor* color = [UIColor colorWithRed:0.114 green:0.705 blue:1 alpha:1];
    UIColor* color2 = [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:1];
    CGSize shadowOffset = CGSizeMake(1.1, 3.1);
    CGFloat shadowBlurRadius = 2;
    
    [layer setFillColor:color.CGColor];
    [layer setStrokeColor:color2.CGColor];
    [layer setLineWidth:3.0];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:shadowOffset];
    [layer setShadowRadius:shadowBlurRadius];
    [layer setShadowOpacity:0.25f];
    [layer setFrame:rect];
    return layer;
}

-(CAShapeLayer *)makeLeaderLineShape {
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self leaderLinePath];
    layer.lineWidth = 2.0f;
    layer.strokeColor = [CENCommon blueBorderColor].CGColor;
    layer.lineDashPattern = @[@2,@4];
    layer.lineCap = kCALineCapRound;
    layer.hidden = YES;
    
    return layer;
}

-(CAShapeLayer *)makeCenterMarkerShape {
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = [self centerMarkerPathWithCenterPoint:[self leaderLineOrigin]];
    CGSize shadowOffset = CGSizeMake(1.1, 3.1);
    CGFloat shadowBlurRadius = 2;
    
    [layer setFillColor:[CENCommon blueFillColor].CGColor];
    [layer setLineWidth:3.0];
    [layer setShadowColor:[UIColor blackColor].CGColor];
    [layer setShadowOffset:shadowOffset];
    [layer setShadowRadius:shadowBlurRadius];
    [layer setShadowOpacity:0.25f];
    [layer setHidden:YES];
    [layer setTransform:CATransform3DMakeScale(0.01, 0.01, 1)];
    return layer;
}

#pragma mark - CAShapeLayer Path Generators

- (CGPathRef)centerMarkerPathWithCenterPoint:(CGPoint)point {
    CGRect rect = [self centerMarkerFrameRectWithCenterPoint:point];
    return [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
}

- (CGRect)centerMarkerFrameRectWithCenterPoint:(CGPoint)point {
    return RectAroundCenter(point, CGSizeMake(12, 12));
}

-(CGPathRef)leaderLinePath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:RectGetCenter(self.searchRadiusSliderCircle.bounds)];
    [path addLineToPoint:RectGetCenter(self.searchRadiusSliderCircle.bounds)];
    return path.CGPath;
}

-(CGPathRef)leaderLinePathFromPoint:(CGPoint)point toPoint:(CGPoint)pointTo {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:pointTo];
    return path.CGPath;
}


-(CGPathRef)radiusSliderButtonPathForRect:(CGRect)rect {
    CGRect newSBRect =  RectAroundCenter(RectGetCenter(rect), CGSizeMake(50, 50));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:newSBRect];
    return path.CGPath;
}

#pragma mark - Visual State

- (void)setLeaderLineHidden:(BOOL)isVisible {
    [self.leaderLine setHidden:isVisible];
    [self.centerMarker setHidden:isVisible];
}

-(void)startDragAnimation {
    [self setLeaderLineHidden:NO];
    [self animateScaleChange:1.75f];
//    [self animateCenterMarkerPopIn];
}

- (void)endDragAnimation {
    [self animateScaleChange:1.0f];
//    [self animateCenterMarkerPopOut];
    [self setLeaderLineHidden:YES];
}

#pragma mark - Animation

- (void)animateScaleChange:(CGFloat)scale {
    [self.searchRadiusSliderCircle setAnchorPoint:CGPointMake(0.5, 0.5)];
    self.searchRadiusSliderCircle.opacity = 1;
    if (!self.currentScale) {
        self.currentScale = scale;
    }
    
    CGFloat overShoot = 0.15;
    overShoot = self.currentScale - scale <= 0 ? overShoot : -overShoot;
    
    CAKeyframeAnimation *kfa = [CAKeyframeAnimation animation];
    kfa.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(self.currentScale-overShoot,
                                                                          self.currentScale-overShoot, 1)],
                     [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale+overShoot, scale+overShoot, 1)],
                     [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1)]];
    kfa.fillMode = kCAFillModeForwards;
    kfa.duration = 0.2f;
    kfa.removedOnCompletion = NO;
    [self.searchRadiusSliderCircle addAnimation:kfa forKey:@"transform"];
    
    self.currentScale = scale;
}

- (void)animateCenterMarkerPopIn {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15f];
    [self.centerMarker setTransform:CATransform3DMakeScale(1.1, 1.1, 1)];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    [self.centerMarker setTransform:CATransform3DMakeScale(1, 1, 1)];
    [UIView commitAnimations];
}

- (void)animateCenterMarkerPopOut {
    CENLogRect(self.centerMarker.frame, @"center marker");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1f];
    [self.centerMarker setTransform:CATransform3DMakeScale(1.1, 1.1, 0)];
    [UIView commitAnimations];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.15f];
    [self.centerMarker setTransform:CATransform3DMakeScale(0.01, 0.01, 0)];
    [UIView commitAnimations];
}


#pragma mark - Live Update

- (void)updateWithTouchPoint:(CGPoint)point andOverlapPoint:(CGPoint)overlapPoint {
    
    CGPoint pointFrom = overlapPoint;
    CGPoint pointTo = RectGetCenter(self.searchRadiusSliderCircle.bounds);
    
    CGFloat distance = distanceBetweenPoints(pointFrom, pointTo);
    CGFloat currentWidth = self.bounds.size.width * self.currentScale;
    CGFloat opacity = MIN(distance,currentWidth)/currentWidth;
    self.searchRadiusSliderCircle.opacity = (float)opacity;
    

    [self.leaderLine setPath:[self leaderLinePathFromPoint:pointFrom toPoint:pointTo]];
    
    if (!CGPointEqualToPoint(overlapPoint, [self centerMarkerCenterPoint])) {
        CGPathRef newPath = [self centerMarkerPathWithCenterPoint:overlapPoint];
        [self.centerMarker setPath: newPath];
    }
}

#pragma mark - Utitlity

- (CGPoint)leaderLineOrigin {
    return [self.viewController overlapCenterPoint];
}

- (CGPoint)centerMarkerCenterPoint {
    return RectGetCenter(self.centerMarker.frame);
}

- (CENSearchRadiusControlAnnotation *)controlAnnotation {
    if ([self.annotation isKindOfClass:[CENSearchRadiusControlAnnotation class]]) {
        return (CENSearchRadiusControlAnnotation *)self.annotation;
    }
    // else
    return nil;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Expand hit box.
    CGRect  touchArea = CGRectInset(self.frame, -15, -15);
    return CGRectContainsPoint(touchArea, point);
}

@end
