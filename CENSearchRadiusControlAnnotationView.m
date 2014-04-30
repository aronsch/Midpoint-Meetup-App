//
//  CENSearchAreaHandleAnnotationView.m
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchRadiusControlAnnotationView.h"
#import "CENCommon.h"

@interface CENSearchRadiusControlAnnotationView ()

@property (strong, nonatomic) CAShapeLayer *searchRadiusSliderCircle;
@property (strong, nonatomic) CAShapeLayer *leaderLine;
@property (nonatomic, assign) CGFloat handleOffset;

@end

@implementation CENSearchRadiusControlAnnotationView

NSString * const caCENSearchAreaHandleAnnotationReuseID = @"CENSearchAreaHandleAnnotation";

+ (instancetype)withAnnotation:(id<MKAnnotation>)annotation andFrame:(CGRect)frame {
    return [[CENSearchRadiusControlAnnotationView alloc] initWithAnnotation:annotation
                                                        reuseIdentifier:caCENSearchAreaHandleAnnotationReuseID
                                                                andFrame:frame];
}

-(id)initWithAnnotation:(id<MKAnnotation>)annotation
        reuseIdentifier:(NSString *)reuseIdentifier
               andFrame:(CGRect)frame {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setFrame:frame];
        [self setOpaque:NO];
        [self setDraggable:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
        [self setSearchRadiusSliderCircle:[self radiusSliderButtonForRect:rect]];
        [self.layer addSublayer:self.searchRadiusSliderCircle];
    }
    
//    // Update Search Area Circle Or Draw If None
//    if (self.leaderLine) {
//        [self.leaderLine setPath:[self leaderLinePathForRect:rect]];
//    }
//    else {
//        [self setLeaderLine:[self leaderLineShapeForRect:rect]];
//        [self.layer addSublayer:self.leaderLine];
//    }
}

-(CAShapeLayer *)radiusSliderButtonForRect:(CGRect)rect {
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [self radiusSliderButtonPathForRect:rect];
    
    UIColor* color = [UIColor colorWithRed:0.114 green:0.705 blue:1 alpha:1];
    UIColor* color2 = [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:1];
    CGSize shadowOffset = CGSizeMake(1.1, 3.1);
    CGFloat shadowBlurRadius = 2;
    
    [circle setFillColor:color.CGColor];
    [circle setStrokeColor:color2.CGColor];
    [circle setLineWidth:3.0];
    [circle setShadowColor:[UIColor blackColor].CGColor];
    [circle setShadowOffset:shadowOffset];
    [circle setShadowRadius:shadowBlurRadius];
    [circle setShadowOpacity:0.34];
    return circle;
}

-(CGPathRef)radiusSliderButtonPathForRect:(CGRect)rect {
    CGRect newSBRect =  RectAroundCenter(RectGetCenter(rect), CGSizeMake(36, 36));
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:newSBRect];
    return path.CGPath;
}

-(CAShapeLayer *)leaderLineShapeForRect:(CGRect)rect {
    
    CAShapeLayer *line = [CAShapeLayer layer];
    line.path = [self leaderLinePathForRect:rect];
    [line setLineWidth:3.0];
    line.strokeColor = [UIColor colorWithRed:0 green:0.59 blue:0.886 alpha:1].CGColor;
    [line setLineDashPattern:@[@5,@2]];
    return line;
}

-(CGMutablePathRef)leaderLinePathForRect:(CGRect)rect {
    CGMutablePathRef linePath = CGPathCreateMutable();
    NSLog(@"rectCenter: x: %f, y: %f",
          self.centerPoint.x,
          self.centerPoint.y);
    CGPathMoveToPoint(linePath,
                      NULL,
                      self.centerPoint.x,
                      self.centerPoint.y);
    CGPathAddLineToPoint(linePath,
                         NULL,
                         CGRectGetMidX(CGPathGetBoundingBox(self.searchRadiusSliderCircle.path))-16,
                         CGRectGetMidY(CGPathGetBoundingBox(self.searchRadiusSliderCircle.path))-16);
    return linePath;
}

#pragma mark - Setters

-(void)setCenterPoint:(CGPoint)centerPoint {
    _centerPoint = centerPoint;
    [self setNeedsDisplay];
}

- (MKMapView *)parentMapView {
    if ([self.superview isKindOfClass:[MKMapView class]]) {
        return (MKMapView *)self.superview;
    }
    return nil;
}

@end
