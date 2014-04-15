//
//  CENMapController.m
//  Center
//
//  Created by Aron Schneider on 4/14/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENMapController.h"
#import "CENCommon.h"

@implementation CENMapController

- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         
     }];
}

@end
