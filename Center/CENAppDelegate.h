//
//  CENAppDelegate.h
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSNumber *cCENDefaultSearchRadius;
extern NSNumber *cCENDefaultSearchBufferDistance;
extern NSNumber *cCENRadiusDeltaTriggeringUpdate;
extern NSNumber *cCENLocationDeltaTriggeringUpdate;

@interface CENAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
