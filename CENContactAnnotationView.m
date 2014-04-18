//
//  CENContactAnnotationView.m
//  Center
//
//  Created by Aron Schneider on 4/16/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactAnnotationView.h"
#import "CENContactAnnotation.h"

@interface CENContactAnnotationView ()

@property (weak, nonatomic) CALayer *overlapCircle;
@property (weak, nonatomic) CALayer *annotationIcon;

@end

@implementation CENContactAnnotationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)configureOverlapCircle {
    
}

- (void)configureAnnotationIcon {
    
}

- (void)drawRect:(CGRect)rect {
    if (!self.overlapCircle) {
        [self configureOverlapCircle];
    }
    if (!self.annotationIcon) {
        [self configureOverlapCircle];
    }
    
    
}


#pragma mark - Convenience Method - Self Cast

- (CENContactAnnotation *)contactAnnotation {
    // If annotation is correct class, return with cast to that class
    if (![self.annotation isKindOfClass:[CENContactAnnotation class]]) {
        return nil;
    }
    return self.annotation;
}

#pragma mark - Convenience Method - CAShapeLayer Creation

- (CAShapeLayer *)makeCACircle:(CGFloat)diameter {
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0,diameter,diameter) cornerRadius:diameter].CGPath;
    circle.bounds = CGRectMake(0, 0, diameter, diameter);
    
    return circle;
}


@end
