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
        CAShapeLayer *baseLayer = [CAShapeLayer layer];
        baseLayer.name = @"Base Background Shape";
        baseLayer.path = [self backgroundLayerPath].CGPath;
        baseLayer.fillColor = [CENCommon blueFillColor].CGColor;
        baseLayer.shadowColor = [UIColor blackColor].CGColor;
        baseLayer.shadowOpacity = 0.15f;
        baseLayer.shadowPath = baseLayer.path;
        baseLayer.shadowOffset = [CENCommon highShadowSize];
        baseLayer.shadowRadius = 1.0f;
        self.strokeLayer = baseLayer;
        [self.layer addSublayer:baseLayer];
    }
    else {
        self.strokeLayer.path = [self backgroundLayerPath].CGPath;
    }
    
    // create or update photo masked to circle
    if (!self.photoLayer && self.image) {
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.name = @"Contact Photo Mask";
        maskLayer.path = [self photoMaskPath].CGPath;
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        self.maskLayer = maskLayer;
        
        CALayer *photoLayer = [self makePhotoLayer];
        [photoLayer setMask:maskLayer];
        self.photoLayer = photoLayer;
        [self.layer addSublayer:photoLayer];
    }
    else {
        self.photoLayer.frame = [self bigCircleRect];
        self.maskLayer.path = [self photoMaskPath].CGPath;
    }
    
    //create badge layer
    if (!self.badgeLayer) {
        CAShapeLayer *badgeLayer = [CAShapeLayer layer];
        badgeLayer.name = @"Information Badge";
        badgeLayer.path = [self badgeCirclePath].CGPath;
        badgeLayer.fillColor = [CENCommon blueFillColor].CGColor;
        badgeLayer.zPosition = 1;
        self.badgeLayer = badgeLayer;
        [self.layer addSublayer:badgeLayer];
    }
    else {
        self.badgeLayer.path = [self badgeCirclePath].CGPath;
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
    CGPoint origin = CGPointMake(CGRectGetMaxX(self.frame)-44, CGRectGetMaxY(self.frame)-44);
    CGRect rect = CGRectMake(origin.x, origin.y, 44, 44);
    return [UIBezierPath bezierPathWithOvalInRect:rect];
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
