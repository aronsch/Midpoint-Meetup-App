//
//  CENMapController.h
//  Center
//
//  Created by Aron Schneider on 4/14/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CENContact;
@class MKPlacemark;

@protocol CENMapControllerProtocol <NSObject>



- (void)addContactAnnotationForContact:(CENContact *)contact;
- (void)removeContactAnnotationForContact:(CENContact *)contact;

- (void)addSearchResults:(NSSet *)searchResults;
- (void)removeSearchResults:(NSSet *)searchResults;
- (void)removeAllSearchResults;

- (void)removeAllAnnotation;

@end

@interface CENMapController : NSObject

- (id)initWithDelegate:(id)delegate;

@end
