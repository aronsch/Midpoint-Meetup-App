//
//  CENContactViewTableViewCell.h
//  Center
//
//  Created by Aron Schneider on 4/10/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CENContactViewTableViewCell : UITableViewCell

extern NSString * const cCENContactCellReuseID;

- (void)setContactPhoto:(UIImage *)photo;
- (void)setName:(NSString *)name;
- (void)setAddress:(NSString *)address;

@end
