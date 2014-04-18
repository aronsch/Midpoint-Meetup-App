//
//  CENContact.h
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import "CENCommon.h"

typedef struct {
    ABRecordRef ABRecordRef;
    int property;
    int identifier;
} CENContactABInfo;

@interface CENContact : NSObject <CENGeoInformationProtocol>

@property (strong, nonatomic) NSDictionary *contact;

#pragma mark - Factory Methods
+ (instancetype)contactWithCENContactABInfo:(CENContactABInfo)abInfo;

#pragma Mark - Init Methods
- (id)initWithABRecordRef:(ABRecordRef)contact andProperty:(int)property andIdentifier:(int)identifier;

#pragma Mark - Contact Information
- (NSString *)firstName;
- (NSString *)lastName;
- (NSString *)nameFirstLast;
- (NSString *)nameLastFirst;
- (NSString *)addressAsString;
- (NSString *)addressAsMultiLineString;
- (NSDictionary *)addressDictionary;
- (UIImage *)contactPhoto;

#pragma Mark - Contact Comparison
- (Boolean)isEqualToABContact:(ABRecordRef)contact;

#pragma mark - CENGeoInformationProtocol
@property (readwrite, strong, nonatomic) CLLocation *location;
- (void)setLocation:(CLLocation *)location;


#pragma mark - CENContactABInfo Struct Macro

#define CENContactABInfoMake(ABRecordRef,property,identifier) {ABRecordRef,property,identifier}

@end
