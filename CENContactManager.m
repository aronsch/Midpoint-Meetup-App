//
//  CENContactManager.m
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactManager.h"

@interface CENContactManager ()

@property (nonatomic, copy) NSNumber *contactID;

@end

@implementation CENContactManager


-(instancetype)init {
    self = [super init];
    if (self) {
        [self setContacts:[[NSMutableArray alloc] init]];
    }
    return self;
}


- (void)addContactWithCENContactABInfo:(CENContactABInfo)abInfo
                       completionBlock:(void (^)(CENContactAddStatus,
                                                 CENContact*))completionBlock {
    if (![self contactRecordExists:abInfo.ABRecordRef]) {
        __block CENContact *contact = [CENContact contactWithCENContactABInfo:abInfo];
        [self.contacts addObject:contact];
        completionBlock(kContactAddSuccess,contact);
    }
    else {
        __block CENContact *existingContact = [self contactForABRecordRef:abInfo.ABRecordRef];
        completionBlock(kFailedContactExists,existingContact);
    }
}

- (void)addContact:(CENContact *)contact {
    if (self.contacts.count == 0) {
    }
    [self.contacts addObject:contact];
    
}

- (void)removeContact:(CENContact *)contact {
    [self.contacts removeObject:contact];
    if (self.contacts.count == 0) {

    }
}

- (CENContact *)contactAtIndex:(NSUInteger)index {
    return (CENContact *)self.contacts[index];
}

- (NSUInteger)indexForContact:(CENContact *)contact {
    return [self.contacts indexOfObject:contact];
}

- (BOOL)contactRecordExists:(ABRecordRef)record {
    for (CENContact *contact in self.contacts) {
        if ([contact isEqualToABContact:record]) {
            return YES;
        }
    }
    return NO;
}

- (CENContact *)contactForABRecordRef:(ABRecordRef)record {
    for (CENContact *contact in self.contacts) {
        if ([contact isEqualToABContact:record]) {
            return contact;
        }
    }
    // else
    return nil;
}

- (NSArray *)addresses {
    NSMutableArray *addresses = [[NSMutableArray alloc] init];
    for (CENContact *contact in self.contacts) {
        [addresses addObject:@{@"contact" : contact,
                               @"address" : contact.addressAsString}];
    }
    
    return addresses;
}



@end
