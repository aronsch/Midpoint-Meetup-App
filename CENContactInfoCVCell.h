//
//  CENContactInfoCVCell.h
//  Center
//
//  Created by Aron Schneider on 5/3/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CENContact;

@interface CENContactInfoCVCell : UICollectionViewCell

extern NSString * const crCENContactInfoCVCellReuseID;

@property (nonatomic, strong) CENContact *contact;

@end
