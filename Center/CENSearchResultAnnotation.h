//
//  CENSearchResultAnnotation.h
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class CENSearchResult;

@interface CENSearchResultAnnotation : NSObject <MKAnnotation>

+ (instancetype)annotationForSearchResult:(CENSearchResult *)searchResult;

@property(readonly, strong, nonatomic) CENSearchResult *searchResult;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@end
