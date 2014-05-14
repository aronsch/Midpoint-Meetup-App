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

-(void)setETA:(NSTimeInterval)eta {
    NSTimeInterval seconds = eta;
    int minutes = (int)round(fmod((seconds/60),60));
    int secondsInMinute = (int)round(fmod(seconds,60));
    int hours = (int)round(minutes/60);
    
    NSString *string = @"";
    
    // Derive number of minutes and remaining seconds for display in "0h 0m (0s)" format.
    
    if (hours >= 1) {
        string = [NSString stringWithFormat:@"%ih %im", hours, minutes];
    }
    else if (seconds >= 60 && secondsInMinute > 0) {
        string = [NSString stringWithFormat:@"%im %is", minutes, secondsInMinute];
    }
    else if (seconds >= 60 && secondsInMinute == 0) {
        string = [NSString stringWithFormat:@"%im", minutes];
    }
    else if (seconds < 60) {
        string = @"<1m";
    }
    self.text = string;
}

- (void)clearETA {
    self.text = @"";
}

@end
