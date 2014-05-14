//
//  CENSearchResult.h
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@class MKMapItem;
@class MKPlacemark;

#import "CENCommon.h"

@interface CENSearchResult : NSObject <CENETAInformationProtocol>

@property (readonly, nonatomic) MKMapItem *mapItem;
@property (readonly, nonatomic) MKPlacemark *placemark;
@property (nonatomic, copy) NSString *name;
@property (readonly, nonatomic) NSURL *url;
@property (readonly,nonatomic, strong) NSMutableDictionary *etaToContacts;

+ (instancetype)resultWithMapItem:(MKMapItem *)mapItem;
- (BOOL)isEqual:(id)object;
- (NSUInteger)hash;

@end
