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

@interface CENContact : NSObject <CENGeoInformationProtocol, CENETAInformationProtocol, NSCoding>

@property (nonatomic, readonly, copy) NSNumber *contactID;
@property (nonatomic, readonly, copy) NSString *firstName;
@property (nonatomic, readonly, copy) NSString *lastName;
@property (nonatomic, readonly) NSDictionary *addressDictionary;

#pragma mark - Factory
+ (instancetype)contactWithCENContactABInfo:(CENContactABInfo)abInfo;

#pragma mark - Update After Decoding
- (void)updateWithInfo:(CENContactABInfo)abInfo;

#pragma Mark - Contact Information
- (NSString *)nameFirstLast;
- (NSString *)nameLastFirst;
- (NSString *)addressAsString;
- (NSString *)addressAsMultiLineString;
- (NSDictionary *)addressDictionary;
- (UIImage *)contactPhoto;
- (CENContactABInfo)addressBookInfo;

#pragma Mark - Contact Comparison
- (Boolean)isEqualToABContact:(ABRecordRef)contact;

#pragma mark - CENGeoInformationProtocol
@property (readwrite, nonatomic) CLLocation *location;
- (void)setLocation:(CLLocation *)location;

#pragma mark - CENETAInformationProtocol
-(MKMapItem *)mapItem;

@end

#pragma mark - CENContactABInfo Struct Make
CENContactABInfo CENContactABInfoMake(ABRecordRef ABRecordRef, int property, int identifier);
