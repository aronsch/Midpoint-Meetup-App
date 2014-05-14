//
//  CENContactInfoCVCell.m
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import MapKit;
#import "CENContactInfoCVCell.h"
#import "CENContact.h"
#import "CENContactTravelInfoPhotoView.h"
#import "CENContactTravelInfoBadgeView.h"
#import "CENCommon.h"

@interface CENContactInfoCVCell ()

@property (weak, nonatomic) IBOutlet CENContactTravelInfoPhotoView *contactPhotoView;
@property (weak, nonatomic) IBOutlet CENContactTravelInfoBadgeView *contactBadgeView;
@property (nonatomic) UILabel *etaLabel;

@end

@implementation CENContactInfoCVCell

NSString * const crCENContactInfoCVCellReuseID = @"CENContactInfoCVCellReuseID";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)setContact:(CENContact *)contact {
    _contact = contact;
    [self.contactPhotoView setImage:[contact contactPhoto]];
    [self subscribeToETANeededNotification];
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

-(void)setETA:(NSTimeInterval)eta {
    if (!self.etaLabel) {
        self.etaLabel = [[UILabel alloc] initWithFrame:[self.contactPhotoView badgeRect]];
        self.etaLabel.font = [UIFont systemFontOfSize:14];
        self.etaLabel.textColor = [UIColor whiteColor];
        self.etaLabel.textAlignment = NSTextAlignmentCenter;
        self.etaLabel.minimumScaleFactor = 0.9;
        [self addSubview:self.etaLabel];
    }
    NSTimeInterval seconds = eta;
    int minutes = (int)round(fmod((seconds/60),60));
    int hours = (int)round(minutes/60);
    
    NSString *string = @"";
    
    // Derive number of minutes and remaining seconds for display in "0h 0m (0s)" format.
    
    if (hours >= 1) {
        string = [NSString stringWithFormat:@"%ih %im", hours, minutes];
    }
    else if (seconds >= 60) {
        string = [NSString stringWithFormat:@"%im", minutes];
    }
    else if (seconds < 60) {
        string = @"<1m";
    }
    self.etaLabel.text = string;
}

- (void)clearETA {
    self.etaLabel.text = @"";
}

#pragma mark - Subscribe to Notifications
- (void)subscribeToETANeededNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENETANeededForResultNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         [self subscribeToETAReturnedNotification];
     }];
}

- (void)subscribeToETAReturnedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENETAReturnedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[MKETAResponse class]]) {
             MKETAResponse *etaResponse = (MKETAResponse *)object;
             
             if ([etaResponse.source isEqual:self.contact.mapItem]) {
                 [self setETA:etaResponse.expectedTravelTime];
             }
         }
     }];
}
@end
