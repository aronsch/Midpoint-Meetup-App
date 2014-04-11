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

typedef struct {
    ABRecordRef ABRecordRef;
    int property;
    int identifier;
} CENContactABInfo;

#define makeCENContactABInfo(ABRecordRef,property,identifier) {ABRecordRef,property,identifier}

@interface CENContact : NSObject

@property (strong, nonatomic) NSDictionary *contact;
@property (strong, nonatomic) CLLocation *location;

#pragma mark - Factory Methods
+ (instancetype)contactWithCENContactABInfo:(CENContactABInfo)abInfo;
+ (instancetype)contactWithABRecordRef:(ABRecordRef)contact andProperty:(int)property andIdentifier:(int)identifier;

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


@end
