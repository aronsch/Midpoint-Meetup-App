//
//  CENLocationManager.h
//  Center
//
//  Created by Aron Schneider on 4/11/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class CLPlacemark;


@interface CENLocationManager : NSObject



@property (readonly, strong, nonatomic) CLLocation *userLocation;

- (void)beginUpdatingLocation;
- (void)stopUpdatingLocation;

#pragma mark - Geocoding Services

- (void)geocodeAddress:(NSString *)address
       completionBlock:(void (^)(BOOL succeeded, CLPlacemark*))completionBlock;

@end
