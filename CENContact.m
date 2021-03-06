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
@property (nonatomic) MKMapItem *mapItem;

@end


@implementation CENContact

//#define ABPersonAddressStreetKey (NSString *)kABPersonAddressStreetKey;
//#define ABPersonAddressZIPKey (NSString *)kABPersonAddressZIPKey;
//#define ABPersonAddressCityKey (NSString *)kABPersonAddressCityKey;
//#define ABPersonAddressStateKey (NSString *)kABPersonAddressStateKey;

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
            d[(NSString *)kABPersonAddressStreetKey],
            d[(NSString *)kABPersonAddressZIPKey],
            d[(NSString *)kABPersonAddressCityKey],
            d[(NSString *)kABPersonAddressStateKey]];
}


- (NSString *)addressAsMultiLineString {
    NSDictionary *d = self.addressDictionary;
    return [NSString stringWithFormat:@"%@\n%@, %@ %@",
            d[(NSString *)kABPersonAddressStreetKey],
            d[(NSString *)kABPersonAddressZIPKey],
            d[(NSString *)kABPersonAddressCityKey],
            d[(NSString *)kABPersonAddressStateKey]];
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
    [self subscribeToETANeededNotification];
}

#pragma mark - CENETAInformationProtocol

-(MKMapItem *)mapItem {
    if (!_mapItem && _location) {
        MKPlacemark *placemark = [[MKPlacemark alloc]
                                  initWithCoordinate:_location.coordinate
                                  addressDictionary:self.addressDictionary];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        mapItem.name = [self nameFirstLast];
        _mapItem = mapItem;
        return mapItem;
    }
    
    return _mapItem;
}

#pragma mark - Utility

#pragma mark Address Book Information Bridging

- (NSValue *)valueWithABInfo:(CENContactABInfo)abInfo {
    return [NSValue value:&abInfo withObjCType:@encode(CENContactABInfo)];
}

- (NSDictionary *)addressDictWithAddressRef:(ABMultiValueRef)addressRef andIdentifier:(int)identifier {
    NSInteger index = ABMultiValueGetIndexForIdentifier(addressRef, identifier);
    NSArray *addressMulti = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(addressRef);
    NSDictionary *dict = [addressMulti objectAtIndex:(NSUInteger)index];
    
    // use stringWithFormat to protect against adding nil objects to dictionary
    NSString *address = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressStreetKey]];
    NSString *zipCode = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressZIPKey]];
    NSString *city = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressCityKey]];
    NSString *state = [NSString stringWithFormat:@"%@", dict[(NSString *)kABPersonAddressStateKey]];
    
    NSDictionary *rDict = @{(NSString *)kABPersonAddressStreetKey:  address,
                            (NSString *)kABPersonAddressZIPKey:     zipCode,
                            (NSString *)kABPersonAddressCityKey:    city,
                            (NSString *)kABPersonAddressStateKey:   state};
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

#pragma mark ETA Request Notification
- (void)emitETARequest:(MKDirectionsRequest *)etaRequest {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENETARequestedNotification
                                                        object:etaRequest];

}

#pragma mark - Notification Subscription

- (void)subscribeToETANeededNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENETANeededForResultNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[MKDirectionsRequest class]]) {
             
             // recieved object can be modified by all subscribers,
             // so we copy to prevent bad access or race conditions.
             MKDirectionsRequest *etaRequest = [(MKDirectionsRequest *)object copy];
             
             // if missing destination property
             if (!etaRequest.destination) {
                 [NSException exceptionWithName:@"MKDirectionsRequest Missing Destination Property"
                                         reason:@"CENETANeeded notification listener expected a MKDirectionsRequest object with a non-nil Destination value."
                                       userInfo:nil];
             }
             
             etaRequest.source = self.mapItem;
             [self emitETARequest:etaRequest];
         }
         else {
             [CENCommon exceptionPayloadClassExpected:[MKDirectionsRequest class]
                                      forNotification:notification];
         }
     }];
}

@end

CENContactABInfo CENContactABInfoMake(ABRecordRef ABRecord, int property, int identifier) {
    CENContactABInfo abInfo = {ABRecord,property,identifier};
    return abInfo;
}
