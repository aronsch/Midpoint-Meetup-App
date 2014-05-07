//
//  CENContactInfoCVCell.m
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactInfoCVCell.h"
#import "CENContact.h"
#import "CENContactTravelInfoPhotoView.h"
#import "CENContactTravelInfoBadgeView.h"

@interface CENContactInfoCVCell ()

@property (weak, nonatomic) IBOutlet CENContactTravelInfoPhotoView *contactPhotoView;
@property (weak, nonatomic) IBOutlet CENContactTravelInfoBadgeView *contactBadgeView;


@end

@implementation CENContactInfoCVCell

NSString * const crCENContactInfoCVCellReuseID = @"CENContactInfoCVCellReuseID";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setContact:(CENContact *)contact {
    _contact = contact;
    [self.contactPhotoView setImage:[contact contactPhoto]];
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *v in self.subviews) {
        if ([v pointInside:point withEvent:event]) {
            return YES;
        }
    }
    // else
    return NO;
}

@end
