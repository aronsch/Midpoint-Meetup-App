//
//  CENContactTravelInfoPhotoView.h
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import UIKit;

@interface CENContactTravelInfoPhotoView : UIView

- (void)setImage:(UIImage *)image;
- (void)updateWithRect:(CGRect)rect;

- (CGRect)badgeRect;
@end
