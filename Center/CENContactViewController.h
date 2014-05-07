//
//  CENContactViewController.h
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CENContactManager;

@interface CENContactViewController : UIViewController

- (void)setContactManager:(CENContactManager *)contactManager;
- (void)presentContactPicker;


@end
