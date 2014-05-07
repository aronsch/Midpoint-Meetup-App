//
//  CENContactTravelInfoPhotoView.m
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactTravelInfoPhotoView.h"
#import "CENCommon.h"

@interface CENContactTravelInfoPhotoView ()

@property (nonatomic) UIImage *image;
@property (nonatomic) CAShapeLayer *photoLayer;

@end

@implementation CENContactTravelInfoPhotoView

@synthesize image = _image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGRect circleRect = CGRectZero;
    circleRect.origin = CGPointZero;
    circleRect.size = sizeForSquareThatFitsRect(rect);
    
    // inset to allow room for border;
    CGRect insetRect = CGRectInset(circleRect, 2, 2);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetShadowWithColor(context,
                                CGSizeMake(0, 9),
                                3.0f,
                                [[UIColor blackColor] colorWithAlphaComponent:0.1].CGColor);
    
    CGContextSetStrokeColorWithColor(context, [CENCommon blueBorderColor].CGColor);
    CGContextSetLineWidth(context, 2.0f);
    
    CGContextFillEllipseInRect(context, insetRect);
    CGContextStrokeEllipseInRect(context, insetRect);
    
    CGContextSaveGState(context);
    {
        CGContextAddEllipseInRect(context, CGRectInset(insetRect, 1, 1));
        CGContextClip(context);
        [self.image drawInRect:insetRect];
    }
    CGContextRestoreGState(context);
    
    
    
    
}


@end
