//
//  CENContactTravelInfoPhotoView.m
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactTravelInfoPhotoView.h"
#import "CENCommon.h"
@import QuartzCore;

@interface CENContactTravelInfoPhotoView ()

@property (nonatomic) UIImage *image;
@property (nonatomic) CAShapeLayer *maskLayer;
@property (nonatomic) CALayer *photoLayer;
@property (nonatomic) CAShapeLayer *strokeLayer;
@property (nonatomic) CAShapeLayer *badgeLayer;
@property (nonatomic) CATextLayer *etaTextLayer;
@property (nonatomic) CGRect frame;

@end

@implementation CENContactTravelInfoPhotoView

@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    return self;
}

- (void)configure {
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
}

- (void)updateWithRect:(CGRect)rect {
    // Ccreate or update circle background
    if (!self.strokeLayer) {
        self.strokeLayer = [CAShapeLayer layer];
        self.strokeLayer.name = @"Base Background Shape";
        self.strokeLayer.path = [self backgroundLayerPath].CGPath;
        self.strokeLayer.fillColor = [CENCommon blueFillColor].CGColor;
        self.strokeLayer.shadowColor = [UIColor blackColor].CGColor;
        self.strokeLayer.shadowOpacity = 0.15f;
        self.strokeLayer.shadowPath = self.strokeLayer.path;
        self.strokeLayer.shadowOffset = [CENCommon highShadowSize];
        self.strokeLayer.shadowRadius = 1.0f;

        [self.layer addSublayer:self.strokeLayer];
    }
    else {
        self.strokeLayer.path = [self backgroundLayerPath].CGPath;
    }
    
    // create or update photo masked to circle
    if (!self.photoLayer && self.image) {
        self.maskLayer = [CAShapeLayer layer];
        self.maskLayer.name = @"Contact Photo Mask";
        self.maskLayer.path = [self photoMaskPath].CGPath;
        self.maskLayer.fillColor = [UIColor whiteColor].CGColor;
        
        self.photoLayer = [self makePhotoLayer];
        [self.photoLayer setMask:self.maskLayer];
        [self.layer addSublayer:self.photoLayer];
    }
    else {
        self.photoLayer.frame = [self bigCircleRect];
        self.maskLayer.path = [self photoMaskPath].CGPath;
    }
    
    //create or update badge text layer
    if (!self.badgeLayer) {
        self.badgeLayer = [CAShapeLayer layer];
        self.badgeLayer.name = @"Information Badge";
        self.badgeLayer.path = [self badgeCirclePath].CGPath;
        self.badgeLayer.fillColor = [CENCommon blueFillColor].CGColor;
        self.badgeLayer.zPosition = 1;
        [self.layer addSublayer:self.badgeLayer];
    }
    else {
        self.badgeLayer.path = [self badgeCirclePath].CGPath;
    }
    
    //create badge text layer
    if (!self.etaTextLayer) {
        self.etaTextLayer = [CATextLayer layer];
        self.etaTextLayer.frame = CGRectOffset(self.badgeLayer.bounds, 10, 0);
        self.etaTextLayer.string = @"";
        self.etaTextLayer.fontSize = 14.0;
        self.etaTextLayer.alignmentMode = kCAAlignmentCenter;
        self.etaTextLayer.wrapped = YES;
        self.etaTextLayer.foregroundColor = [UIColor whiteColor].CGColor;
        [self.badgeLayer addSublayer:self.etaTextLayer];
    }
    else {
        self.etaTextLayer.frame = [self badgeRect];
    }
}

- (CGRect)bigCircleRect {
    CGSize rectSize = sizeForSquareThatFitsRect(self.frame);
    CGRect circleRect = CGRectMake(_frame.origin.x, _frame.origin.y, rectSize.width - 15, rectSize.height - 15);
    return circleRect;
}

- (CALayer *)makePhotoLayer {
    CALayer *layer = [CALayer layer];
    layer.frame = [self bigCircleRect];
    layer.contents = (id)self.image.CGImage;
    return layer;
}

-(UIBezierPath *)backgroundLayerPath {
    CGRect rect = [self bigCircleRect];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect
                                                    cornerRadius:rect.size.width];
    [path appendPath:[self badgeCirclePath]];
    return path;
}

-(UIBezierPath *)photoMaskPath {
    CGRect insetRect = CGRectInset([self bigCircleRect], 2, 2);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:insetRect.size.width];
    return maskPath;
}

-(UIBezierPath *)badgeCirclePath {
    return [UIBezierPath bezierPathWithOvalInRect:[self badgeRect]];
}

- (CGRect)badgeRect {
    CGPoint origin = CGPointMake(CGRectGetMaxX(self.frame)-44, CGRectGetMaxY(self.frame)-44);
    return CGRectMake(origin.x, origin.y, 44, 44);
}

-(void)setImage:(UIImage *)image {
    _image = image;
    [self updateWithRect:self.frame];
}

-(void)setFrame:(CGRect)frame {
    _frame = frame;
    [self updateWithRect:frame];
}
@end
