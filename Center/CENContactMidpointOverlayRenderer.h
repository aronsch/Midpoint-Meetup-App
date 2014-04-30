//
//  CENContactMidpointOverlayRenderer.h
//  Center
//
//  Created by Aron Schneider on 4/26/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface CENContactMidpointOverlayRenderer : MKOverlayRenderer

+(instancetype)withOverlay:(id<MKOverlay>)overlay;
-(void)setSearchRadius:(MKMapSize)searchRadius;

@end
