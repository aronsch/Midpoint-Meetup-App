//
//  CENContactManager.h
//  Center
//
//  Created by Aron Schneider on 4/9/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "CENContact.h"
#import "CENCommon.h"

typedef enum {
    kFailedContactExists,
    kContactAddSuccess
} CENContactAddStatus;

@interface CENContactManager : NSObject

@property (readonly,strong, nonatomic) NSMutableArray *contacts;

- (instancetype)init;

- (void)addContactWithCENContactABInfo:(CENContactABInfo)abInfo
                       completionBlock:(void (^)(CENContactAddStatus status, CENContact* contact))completionBlock;

- (void)addContact:(id)contact;
- (void)removeContact:(id)contact;
- (BOOL)contactRecordExists:(ABRecordRef)record;
- (id)contactForABRecordRef:(ABRecordRef)record;
- (id)contactAtIndex:(NSUInteger)index;
- (NSUInteger)indexForContact:(id)contact;
- (NSArray *)addresses;
@end
