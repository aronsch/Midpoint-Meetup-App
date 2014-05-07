//
//  CENContactMidpointOverlay.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

@import Foundation;
@import MapKit;

@interface CENContactMidpointOverlay : NSObject <MKOverlay>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andBoundingMapRect:(MKMapRect)mapRect;

@end
