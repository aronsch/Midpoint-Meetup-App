//
//  CENPassTouchView.m
//  Center
//
//  Created by Aron Schneider on 5/10/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENPassTouchView.h"

@implementation CENPassTouchView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    for (UIView *view in self.subviews) {
        pointInside = [view pointInside:point withEvent:event];
        if (pointInside) {
            break;
        }
    }
    return pointInside;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
