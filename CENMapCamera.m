//
//  CENMapCamera.m
//  Center
//
//  Created by Aron Schneider on 4/17/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENMapCamera.h"
#import "CENCommon.h"

@implementation CENMapCamera

@synthesize pitch = _pitch, altitude = _altitude, heading = _heading, centerCoordinate = _centerCoordinate;

-(id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self addObserver:self forKeyPath:@"altitude" options:NSKeyValueObservingOptionNew context:nil];
    
    return self;
}

-(void)setPitch:(CGFloat)pitch {
    _pitch = pitch;
    [self emitChangeNotification];
}

-(void)setAltitude:(CLLocationDistance)altitude {
    _altitude = altitude;
    [self emitChangeNotification];
}

- (void)setHeading:(CLLocationDirection)heading {
    _heading = heading;
    [self emitChangeNotification];
}

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate {
    _centerCoordinate = centerCoordinate;
    [self emitChangeNotification];
}

- (void)emitChangeNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENMapCameraMovedNotification object:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        NSLog(@"%@", keyPath);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
