//
//  CENAddContactCVCell.m
//  Center
//
//  Created by Aron Schneider on 5/4/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENAddContactCVCell.h"
#import "CENCommon.h"

@implementation CENAddContactCVCell

NSString * const crCENAddContactCVCellReuseID = @"CENAddContactCVCellReuseID";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    
    rect = RectAroundCenter(RectGetCenter(rect), CGSizeMake(rect.size.height, rect.size.height));
    rect = CGRectInset(rect, 10, 10);
    
    NSString *label = @"+";
    NSDictionary *fontAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:66],
                                     NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    {
        CGContextSetShadowWithColor(context,
                                    CGSizeMake(0, 10),
                                    3.0f,
                                    [[UIColor blackColor] colorWithAlphaComponent:0.15].CGColor);
        CGContextSetFillColorWithColor(context, [CENCommon blueFillColor].CGColor);
        CGContextFillEllipseInRect(context, rect);
        
    }
    CGContextRestoreGState(context);
    [label drawAtPoint:CGPointMake(30, -1) withAttributes:fontAttributes];
    
    CGContextAddEllipseInRect(context, rect);
    
    
}


@end
