//
//  CENSearchResult.h
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CENSearchResult : NSObject

@property (readonly, strong, nonatomic) MKPlacemark *placemark;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int rating;
@property (readonly,nonatomic, strong) NSMutableDictionary *etaToContacts;

@end
