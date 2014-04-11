//
//  CENContactViewTableViewCell.m
//  Center
//
//  Created by Aron Schneider on 4/10/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactViewTableViewCell.h"

@interface CENContactViewTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *contactPhotoView;
@property (weak, nonatomic) IBOutlet UILabel *contactNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactAddressLabel;


@end

@implementation CENContactViewTableViewCell

NSString * const cCENContactCellReuseID = @"contact cell";

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

-(void)setName:(NSString *)name {
    [self.contactNameLabel setText:name];
}

- (void)setAddress:(NSString *)address {
    [self.contactAddressLabel setText:address];
}

- (void)setContactPhoto:(UIImage *)photo {
    [self.contactPhotoView setImage:photo];
}

@end
