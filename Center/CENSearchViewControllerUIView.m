//
//  CENSearchViewControllerUIView.m
//  Center
//
//  Created by Aron Schneider on 5/10/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchViewControllerUIView.h"
#import "CENCommon.h"

@implementation CENSearchViewControllerUIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.frame, point);
}


@end
