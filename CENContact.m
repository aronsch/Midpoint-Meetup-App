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
//@property (readwrite, strong, nonatomic) CLLocation *location;

@end


@implementation CENContact

#pragma mark - Init

+(instancetype)contactWithCENContactABInfo:(CENContactABInfo)abInfo {
    return [[CENContact alloc] initWithABRecordRef:abInfo.ABRecordRef
                                andProperty:abInfo.property
                                     andIdentifier:abInfo.identifier];
}

- (id)initWithABRecordRef:(ABRecordRef)contact andProperty:(int)property andIdentifier:(int)identifier
{
    self = [super init];
    if (self) {
        [self setupWith:contact property:property identifier:identifier];
    }
    return self;
}

- (void)setupWith:(ABRecordRef)contact property:(int)property identifier:(int)identifier {
    self.contact = @{@"firstName":[self stringWithABRecord:contact forProperty:kABPersonFirstNameProperty],
                    @"lastName": [self stringWithABRecord:contact forProperty:kABPersonLastNameProperty],
                    @"addressDict": [self addressDictWithAddressRef:ABRecordCopyValue(contact, property) andIdentifier:identifier],
                    @"imageData": [self thumbnailForABContact:contact]};
    
    self.contactID = [NSNumber numberWithInt:ABRecordGetRecordID(contact)];
    [self emitGeocodingRequest];
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

- (NSString *)firstName {
    return self.contact[@"firstName"];
}

- (NSString *)lastName {
    return self.contact[@"lastName"];
}

- (NSString *)nameFirstLast {
    return [NSString stringWithFormat:@"%@ %@",
            self.contact[@"firstName"], self.contact[@"lastName"]];
}

- (NSString *)nameLastFirst {
    return [NSString stringWithFormat:@"%@, %@",
            self.contact[@"lastName"], self.contact[@"firstName"]];
}

- (NSString *)addressAsString {
    NSDictionary *d = self.contact[@"addressDict"];
    return [NSString stringWithFormat:@"%@, %@, %@ %@",
            d[@"address"], d[@"city"], d[@"state"], d[@"zipCode"]];
}

- (NSString *)addressAsMultiLineString {
    NSDictionary *aD = [self addressDictionary];
    return [NSString stringWithFormat:@"%@\n%@, %@ %@",
            aD[@"address"], aD[@"city"], aD[@"state"], aD[@"zipCode"]];
}

- (NSDictionary *)addressDictionary {
    return self.contact[@"addressDict"];
}

- (UIImage *)contactPhoto {
    return [self imageUIImageWithData:self.contact[@"imageData"]];
}

#pragma mark - CENGeoInformationProtocol

// Custom Location setter dispatches notification
-(void)setLocation:(CLLocation *)location {
    _location = location;
    [self emitLocationAvailable];
}

#pragma mark - Utility

#pragma mark Address Book Information Bridging
// When working with c dicts, StringWithFormat protects against returning nil objects.
- (NSDictionary *)addressDictWithAddressRef:(ABMultiValueRef)addressRef andIdentifier:(int)identifier {
    NSUInteger index = ABMultiValueGetIndexForIdentifier(addressRef, identifier);
    NSArray *addressMulti = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(addressRef);
    NSDictionary *dict = [addressMulti objectAtIndex:index];
    
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

@end
