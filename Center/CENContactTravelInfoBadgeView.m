//
//  CENContactTravelInfoBadgeView.m
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactTravelInfoBadgeView.h"
#import "CENCommon.h"

@interface CENContactTravelInfoBadgeView ()

@property (nonatomic) NSString *text;

@end

@implementation CENContactTravelInfoBadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [CENCommon blueFillColor].CGColor);
    CGContextFillEllipseInRect(context, rect);
}


@end
