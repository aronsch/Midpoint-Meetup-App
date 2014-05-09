//
//  CENContact.m
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContact.h"

@interface CENContact ()

@property (nonatomic, copy) NSNumber *contactID;
@property (nonatomic) NSValue *contactABInfo;
@property (nonatomic, copy, readwrite) NSString *firstName;
@property (nonatomic, copy, readwrite) NSString *lastName;
@property (nonatomic, readwrite) NSDictionary *addressDictionary;
@property (nonatomic) NSData *photoData;

@end


@implementation CENContact

#pragma mark - Init

+(instancetype)contactWithCENContactABInfo:(CENContactABInfo)abInfo {
    return [[CENContact alloc] initWithABInfo:abInfo];
}

- (id)initWithABInfo:(CENContactABInfo)abInfo
{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self configureWith:abInfo];
    return self;
}

#pragma mark - NSCoding Protocol

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.contactID = [aDecoder decodeObjectForKey:@"contactID"];
    self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
    self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
    self.addressDictionary = [aDecoder decodeObjectForKey:@"addressDictionary"];
    self.location = [aDecoder decodeObjectForKey:@"location"];
    self.contactABInfo = [aDecoder decodeObjectForKey:@"contactABInfo"];
    
    [self emitContactUpdateRequest];
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.contactID forKey:@"contactID"];
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.addressDictionary forKey:@"addressDictionary"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeObject:self.contactABInfo forKey:@"contactABInfo"];
}

#pragma mark - Configuration with ABRecordRef

- (void)updateWithInfo:(CENContactABInfo)abInfo {
    [self configureWith:abInfo];
}

- (void)configureWith:(CENContactABInfo)abInfo {
    if ([self abInfoHasNullValues:abInfo]) {
        [self emitRemoveSelf];
        return;
    }
    
    self.firstName = [self stringWithABRecord:abInfo.ABRecordRef
                                  forProperty:kABPersonFirstNameProperty];
    self.lastName = [self stringWithABRecord:abInfo.ABRecordRef
                                 forProperty:kABPersonLastNameProperty];
    self.addressDictionary = [self addressDictWithAddressRef:ABRecordCopyValue(abInfo.ABRecordRef, abInfo.property)
                                               andIdentifier:abInfo.identifier];
    self.photoData = [self thumbnailForABContact:abInfo.ABRecordRef];
    self.contactID = [NSNumber numberWithInt:ABRecordGetRecordID(abInfo.ABRecordRef)];
    self.contactABInfo = [self valueWithABInfo:abInfo];
    
    if (!self.location) {
        [self emitGeocodingRequest];
    }
}

- (BOOL)abInfoHasNullValues:(CENContactABInfo)abInfo {
    return (abInfo.ABRecordRef == NULL || isnumber(abInfo.property) || isnumber(abInfo.identifier));
}

- (NSData *)thumbnailForABContact:(ABRecordRef)contact {
    if (!ABPersonHasImageData(contact)) {
        return [self defaultContactThumbnail];
    }
    
    return (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(contact, kABPersonImageFormatThumbnail);
}

- (NSData *)defaultContactThumbnail {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"defaultContactThumbnail" ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    return data;
}

#pragma mark Contact Information

- (NSString *)nameFirstLast {
    return [NSString stringWithFormat:@"%@ %@",
            self.firstName, self.lastName];
}

- (NSString *)nameLastFirst {
    return [NSString stringWithFormat:@"%@, %@",
            self.lastName, self.firstName];
}

- (NSString *)addressAsString {
    NSDictionary *d = self.addressDictionary;
    return [NSString stringWithFormat:@"%@, %@, %@ %@",
            d[@"address"], d[@"city"], d[@"state"], d[@"zipCode"]];
}

- (NSString *)addressAsMultiLineString {
    NSDictionary *aD = self.addressDictionary;
    return [NSString stringWithFormat:@"%@\n%@, %@ %@",
            aD[@"address"], aD[@"city"], aD[@"state"], aD[@"zipCode"]];
}

- (UIImage *)contactPhoto {
    return [self imageUIImageWithData:self.photoData];
}

- (CENContactABInfo)addressBookInfo {
    CENContactABInfo abInfo;
    [self.contactABInfo getValue:&abInfo];
    return abInfo;
}

#pragma mark - CENGeoInformationProtocol

// Custom Location setter dispatches notification
-(void)setLocation:(CLLocation *)location {
    _location = location;
    [self emitLocationAvailable];
}

#pragma mark - Utility

#pragma mark Address Book Information Bridging

- (NSValue *)valueWithABInfo:(CENContactABInfo)abInfo {
    return [NSValue value:&abInfo withObjCType:@encode(CENContactABInfo)];
}
// When working with c dicts, StringWithFormat protects against returning nil objects.
- (NSDictionary *)addressDictWithAddressRef:(ABMultiValueRef)addressRef andIdentifier:(int)identifier {
    NSInteger index = ABMultiValueGetIndexForIdentifier(addressRef, identifier);
    NSArray *addressMulti = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(addressRef);
    NSDictionary *dict = [addressMulti objectAtIndex:(NSUInteger)index];
    
    NSString *address = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressStreetKey]];
    NSString *zipCode = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressZIPKey]];
    NSString *city = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressCityKey]];
    NSString *state = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressStateKey]];
    
    NSDictionary *rDict = @{@"address":  address,
                            @"zipCode":  zipCode,
                            @"city":     city,
                            @"state":    state};
    return rDict;
}

- (NSString *)stringWithABRecord:(ABRecordRef)contact forProperty:(ABPropertyID)property {
    NSString *string = @"";
    if ((__bridge_transfer NSString *)ABRecordCopyValue(contact, property)) {
        string = [NSString stringWithFormat:@"%@",
                  (__bridge_transfer NSString *)ABRecordCopyValue(contact, property)];
    }
    return string;
}

- (UIImage *)imageUIImageWithData:(NSData *)data {
    return [UIImage imageWithData:data];
}

# pragma mark Contact Comparison

- (Boolean)isEqualToABContact:(ABRecordRef)contact {
    ABRecordID contactID = ABRecordGetRecordID(contact);
    return [self.contactID intValue] == contactID;
}


#pragma mark - Notification Emission

- (void)emitGeocodingRequest {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENGeocodeRequestedNotification object:self];
}

- (void)emitLocationAvailable {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENLocationAvailableNotification object:self];
}

- (void)emitContactUpdateRequest {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENContactUpdateRequestedNotification object:self];
}

- (void)emitRemoveSelf {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENContactRemovedNotification object:self];
}

@end

CENContactABInfo CENContactABInfoMake(ABRecordRef ABRecord, int property, int identifier) {
    CENContactABInfo abInfo = {ABRecord,property,identifier};
    return abInfo;
}
