//
//  CENContactAnnotaion.m
//  Center
//
//  Created by Aron Schneider on 4/15/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactAnnotation.h"
#import "CENContact.h"

@implementation CENContactAnnotation

+(instancetype)annotationForContact:(CENContact *)contact {
    return [[self alloc] initWithContact:contact];
}

-(id)initWithContact:(CENContact *)contact {
    self = [super init];
    if (!self) {
        return nil;
    }
    _contact = contact;
    [self configure];
    return self;
}

- (void)configure {
    [self setTitle:[self.contact nameFirstLast]];
    [self setSubtitle:@""];
    [self setContactImage:[self.contact contactPhoto]];
    [self setCoordinate:self.contact.location.coordinate];
}

-(CLLocation *)location {
    return CLLocationMake(self.coordinate.latitude, self.coordinate.longitude);
}
@end
