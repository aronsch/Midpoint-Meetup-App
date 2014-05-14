//
//  CENViewController.m
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENViewController.h"
#import <MapKit/MapKit.h>
#import "CENSearchViewController.h"
#import "CENContactViewController.h"
#import "CENTravelInfoViewController.h"
#import "CENLocationController.h"
#import "CENContactManager.h"
#import "CENContactAnnotation.h"
#import "CENSearchResultAnnotation.h"
#import "CENMapController.h"
#import "CENCommon.h"
#import "CENContactsMidpointAnnotation.h"
#import "CENContactMidpointAnnotationView.h"
#import "CENSearchRadiusControlAnnotation.h"
#import "CENSearchRadiusControlAnnotationView.h"
#import "CENMapView.h"
#import "CENContactMidpointOverlayRenderer.h"
#import "CENContactMidpointOverlay.h"
#import "CENSearchResult.h"


@interface CENViewController () <MKMapViewDelegate,CENMapControllerProtocol>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CENSearchViewController *searchViewController;
@property (strong, nonatomic) CENContactViewController *contactViewController;
@property (strong, nonatomic) CENTravelInfoViewController *travelInfoViewController;
@property (strong, nonatomic) UIView *searchPullTab;
@property (strong, nonatomic) UIView *contactPullTab;
@property (strong, nonatomic) NSMutableDictionary *searchPullTabViews;
@property (strong, nonatomic) NSMutableDictionary *contactPullTabViews;

@property (strong, nonatomic) CENLocationController *locationManager;
@property (strong, nonatomic) CENContactManager *contactManager;
@property (strong, nonatomic) CENMapController *mapController;


// Annotations
@property (strong, nonatomic) NSMutableArray *contactAnnotations;
@property (strong, nonatomic) NSMutableSet *searchResultAnnotations;
@property (strong, nonatomic) CENContactsMidpointAnnotation *midPointAnnotation;
@property (strong, nonatomic) CENSearchRadiusControlAnnotation *midPointSearchAreaHandleAnnotation;

// Annotation Views
@property (strong, nonatomic) CENContactMidpointAnnotationView *midPointAnnotationView;
@property (strong, nonatomic) CENSearchRadiusControlAnnotationView *searchRadiusControlView;
@property (nonatomic) MKAnnotationViewDragState searchRadiusControlDragState;

// Overlay Views
@property (strong, nonatomic) CENContactMidpointOverlayRenderer *midpointOverlapRenderer;

@property (nonatomic, assign) CLLocationDistance searchRadius;
@property (nonatomic, strong) CLLocation *userLocation;
@property (atomic, strong) NSMutableArray *overlapCircles;

typedef enum {
    kPanLeft,
    kPanRight,
    kNoPan
} CENPanDirection;

@end

@implementation CENViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configure];
}

- (void)configure {
    [self setSearchRadius:CENDefaultSearchRadius];
//    [self setupSearchPullTab];
//    [self setupContactPullTab];
    [self setLocationManager:[[CENLocationController alloc] init]];
    [self setMapController:[[CENMapController alloc] initWithDelegate:self]];
    [self.locationManager beginUpdatingLocation];
    [self subscribeToNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Drawer Views Configuration

- (void)setupSearchPullTab {
    CGRect pullTabRect = CGRectMake(0, 100, 66, 66);
    UIView *pullTabView = [[UIView alloc] initWithFrame:pullTabRect];
    [pullTabView setBackgroundColor:[UIColor clearColor]];
    [self setSearchPullTab:pullTabView];
    NSMutableDictionary *groupDict = [NSMutableDictionary
                                      dictionaryWithDictionary:@{@"tab": pullTabView,
                                                                 @"target view": self.searchViewController.view.superview,
                                                                 @"side": @"left",
                                                                 @"drawer visible": @NO}];
    [self setSearchPullTabViews:groupDict];
    [self.view addSubview:pullTabView];
    [self.view bringSubviewToFront:pullTabView];
    [self configurePanGestureRecognizers];
}

- (void)setupContactPullTab {
    CGRect pullTabRect = CGRectMake([self viewMaxX]-66, 168, 66, 66);
    UIView *pullTabView = [[UIView alloc] initWithFrame:pullTabRect];
    [pullTabView setBackgroundColor:[UIColor whiteColor]];
    [self setContactPullTab:pullTabView];
    NSMutableDictionary *groupDict = [NSMutableDictionary
                                      dictionaryWithDictionary:@{@"tab": pullTabView,
                                                                 @"target view": self.contactViewController.view.superview,
                                                                 @"side": @"right",
                                                                 @"drawer visible": @NO}];
    [self setContactPullTabViews:groupDict];
    [self.view addSubview:pullTabView];
    [self.view bringSubviewToFront:pullTabView];
    [self configurePanGestureRecognizers];
}

-(void)presentContactPicker {
    [self.contactViewController presentContactPicker];
}


#pragma mark - Drawer Views Gesture Recognizer Configuration

- (void)configurePanGestureRecognizers {
    UIPanGestureRecognizer *searchTabPanGR = [[UIPanGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(handleLeftDrawerPan:)];
    
    UIPanGestureRecognizer *contactTabPanGR = [[UIPanGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handleRightDrawerPan:)];
    
    
    [self.searchViewController.view.superview addGestureRecognizer:searchTabPanGR];
    [self.searchPullTab addGestureRecognizer:searchTabPanGR];
    
    [self.contactViewController.view.superview addGestureRecognizer:contactTabPanGR];
    [self.contactPullTab addGestureRecognizer:contactTabPanGR];
    
}


#pragma mark - Gesture Handling

- (void)handleLeftDrawerPan:(UIPanGestureRecognizer *)panGR {
    [self drawerPan:panGR withTabViewGroup:self.searchPullTabViews];
}

- (void)handleRightDrawerPan:(UIPanGestureRecognizer *)panGR {
    [self drawerPan:panGR withTabViewGroup:self.contactPullTabViews];
}


- (void)drawerPan:(UIPanGestureRecognizer *)panGR
     withTabViewGroup:(NSMutableDictionary *)tabViewGroup {
    
    [self closeOppositeForTabViewGroup:tabViewGroup];
    CGFloat xTranslation = [panGR translationInView:self.view].x;
    CGFloat xVelocity = [panGR velocityInView:self.view].x;
    
    UIView* tabView = tabViewGroup[@"tab"];
    UIView* targetView = tabViewGroup[@"target view"];
    
    CGRect tabNewFrame = CGRectOffset(tabView.frame, xTranslation, 0);
    CGRect targetNewFrame = CGRectOffset(targetView.frame, xTranslation, 0);
    
    BOOL isLeftOriented = [tabViewGroup[@"side"] isEqualToString:@"left"];
    BOOL isRightOriented = !isLeftOriented;
    BOOL isInBoundsLeft = [self rectsWithinLeftBoundsForTabRect:tabNewFrame
                                                  andTargetRect:targetNewFrame];
    BOOL isInBoundsRight = [self rectsWithinRightBoundsForTabRect:tabNewFrame
                                                    andTargetRect:targetNewFrame];
    
    // pan if tab is in view and outer edge of drawer
    // has not reached outer edge of view
    if ((isLeftOriented && isInBoundsLeft) ||
        (!isLeftOriented && isInBoundsRight)) {
            tabView.frame = tabNewFrame;
            targetView.frame = targetNewFrame;
    }
    
    if ([panGR state] == UIGestureRecognizerStateEnded) {
        if ((xVelocity > 0 && isLeftOriented) ||
            (xVelocity < 0 && isRightOriented)) {
            [self showTabViewGroup:tabViewGroup];
        }
        else if ((xVelocity < 0 && isLeftOriented) ||
                 (xVelocity > 0 && isRightOriented)) {
            [self hideTabViewGroup:tabViewGroup];
        }
    }
    
    [panGR setTranslation:CGPointZero inView:self.view];
}


#pragma mark - UI Animation

- (void)hideTabViewGroup:(NSMutableDictionary *)tabViewGroup {
    UIView *tabView = tabViewGroup[@"tab"];
    UIView *targetView = tabViewGroup[@"target view"];
    CGRect tabNewFrame = tabView.frame;
    CGRect targetNewFrame = targetView.frame;
    
    if ([tabViewGroup[@"side"] isEqualToString:@"left"]) {
        tabNewFrame.origin.x = 0;
        targetNewFrame.origin.x = -targetNewFrame.size.width;
    }
    else if ([tabViewGroup[@"side"] isEqualToString:@"right"]) {
        tabNewFrame.origin.x = [self viewMaxX] - tabNewFrame.size.width;
        targetNewFrame.origin.x = [self viewMaxX];
    }
    [UIView animateWithDuration:0.15f
                     animations:^{
                         [tabView setFrame:tabNewFrame];
                         [targetView setFrame:targetNewFrame];
                     }
                     completion:^(BOOL finished){
                         tabViewGroup[@"drawer visible"] = @NO;
                     }];
}

- (void)showTabViewGroup:(NSMutableDictionary *)tabViewGroup {
    UIView *tabView = tabViewGroup[@"tab"];
    UIView *targetView = tabViewGroup[@"target view"];
    CGRect tabNewFrame = tabView.frame;
    CGRect targetNewFrame = targetView.frame;
    
    if ([tabViewGroup[@"side"] isEqualToString:@"left"]) {
        tabNewFrame.origin.x = targetNewFrame.size.width;
        targetNewFrame.origin.x = 0;
    }
    else if ([tabViewGroup[@"side"] isEqualToString:@"right"]) {
        tabNewFrame.origin.x = [self viewMaxX] - targetNewFrame.size.width - tabNewFrame.size.width;
        targetNewFrame.origin.x = [self viewMaxX] - targetNewFrame.size.width;
    }
    [UIView animateWithDuration:0.15f
                     animations:^{
                         [tabView setFrame:tabNewFrame];
                         [targetView setFrame:targetNewFrame];
                     }
                     completion:^(BOOL finished){
                         tabViewGroup[@"drawer visible"] = @YES;
                     }];
}


#pragma mark - Overlap Circle Overlay Methods

- (void)setUpMidpointOverlap {
    if (![self overlapCircles]) {
        [self setOverlapCircles:[[NSMutableArray alloc] init]];
    }
    [self removeOverlapCircles];
    [self midpointOverlap];
    [self updateMidpointAnnotations];
    [self emitSearchRegionDidChangeNotification];
}

- (void)midpointOverlap {
    if (self.contactAnnotations.count > 1) {
        CENContactMidpointOverlay *overlay = [[CENContactMidpointOverlay alloc]
                                              initWithCoordinate:self.midPointAnnotation.coordinate
                                              andBoundingMapRect:[self mapRectBoundingAllOverlapRegions]];

        [self.mapView addOverlay:overlay level:MKOverlayLevelAboveLabels];
    }
}

- (void)removeOverlapCircles {
    [self.mapView removeOverlays:self.mapView.overlays];
}

- (void)updateMidpointAnnotations {
    CLLocation *newMidpoint = [self contactsMidpoint];
    if (self.midPointAnnotation) {
        [self.midPointAnnotation setLocation:newMidpoint];
    }
    else {
        CENContactsMidpointAnnotation *mpa = [[CENContactsMidpointAnnotation alloc]
                                              initWithLocation:newMidpoint];
        [self setMidPointAnnotation:mpa];
        [self.mapView addAnnotation:self.midPointAnnotation];
        [self emitSearchRadiusChangedNotification];
        
    }
    
    CLLocation *searchRadiusControlLoc = CLLocationWithCLLocationCoordinate2D([self searchRadiusControlCoordinate]);
    
    
    if (self.midPointSearchAreaHandleAnnotation) {
        
        // if this annotation has not been moved by the user, place it in it's default position.
        if (![[self.searchRadiusControlView controlAnnotation] hasBeenMoved]) {
            [self.midPointSearchAreaHandleAnnotation setLocation:searchRadiusControlLoc];
        }
        
    }
    else {
        CENSearchRadiusControlAnnotation *handle = [CENSearchRadiusControlAnnotation annotationWithLocation:searchRadiusControlLoc];
        [self setMidPointSearchAreaHandleAnnotation:handle];
        [self.mapView addAnnotation:self.midPointSearchAreaHandleAnnotation];
    }
    
    [self.midPointAnnotationView setNeedsDisplay];
    [self.searchRadiusControlView setNeedsDisplay];
}


#pragma mark - MKMapviewDelegate Protocol

#pragma mark Annotation Selection (MKMapviewDelegate Protocol)

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([[view reuseIdentifier] isEqualToString:@"CENSearchResultAnnotation"]) {
        CENSearchResult *result = [(CENSearchResultAnnotation *)view.annotation searchResult];
        [self emitETANeededNotificationForResult:result];
    }
}

#pragma mark Annotation Views (MKMapviewDelegate Protocol)

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    
    // Midpoint Search Area Annotation View
    if ([annotation isKindOfClass:[CENContactsMidpointAnnotation class]]) {
        if (self.midPointAnnotationView) {
            [self.midPointAnnotationView setAnnotation:annotation];
        }
        else {
            self.midPointAnnotationView = [CENContactMidpointAnnotationView withAnnotation:annotation andFrame:[self searchRegionCGRect]];
        }
        return self.midPointAnnotationView;
    }
    
    // Midpoint Search Area Drag Handle Annotation View
    if ([annotation isKindOfClass:[CENSearchRadiusControlAnnotation class]]) {
        if (self.searchRadiusControlView) {
            [self.searchRadiusControlView setAnnotation:annotation];
        }
        else {
            self.searchRadiusControlView = [CENSearchRadiusControlAnnotationView
                                            withAnnotation:annotation andCenter:[self overlapCenterPoint]
                                            forViewController:self];
        }
        return self.searchRadiusControlView;
        [self.mapView bringSubviewToFront:self.searchRadiusControlView];
    }

    // Contact Annotation View
    if ([annotation isKindOfClass:[CENContactAnnotation class]]) {
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CENContactAnnotation"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CENContactAnnotation"];
            annotationView.canShowCallout = YES;
        }
        return annotationView;
    }
    
    // Search Result View
    if ([annotation isKindOfClass:[CENSearchResultAnnotation class]]) {
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CENSearchResultAnnotation"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CENSearchResultAnnotation"];
            annotationView.canShowCallout = YES;
        }
        return annotationView;
    }
    
    return nil;
}

#pragma mark Draggable Annotations (MKMapviewDelegate Protocol)

-(void)mapView:(MKMapView *)mapView
annotationView:(MKAnnotationView *)view
didChangeDragState:(MKAnnotationViewDragState)newState
  fromOldState:(MKAnnotationViewDragState)oldState {
    if ([view isKindOfClass:[CENSearchRadiusControlAnnotationView class]]) {
        [self handleSearchRadiusControlDragwithmapView:mapView
                                        annotationView:view
                                    didChangeDragState:newState
                                          fromOldState:oldState];
    }
}

- (void)handleSearchRadiusControlDragwithmapView:(MKMapView *)mapView
                                  annotationView:(MKAnnotationView *)view
                              didChangeDragState:(MKAnnotationViewDragState)newState
                                    fromOldState:(MKAnnotationViewDragState)oldState {
    
    CENSearchRadiusControlAnnotation *controlAnnotation = view.annotation;
    CENSearchRadiusControlAnnotationView *controlView = (CENSearchRadiusControlAnnotationView *)view;
    
    if (newState == MKAnnotationViewDragStateEnding) {
        self.searchRadiusControlDragState = MKAnnotationViewDragStateNone;
        
        [controlView endDragAnimation];
        CLLocation *controlAnnotationLoc = [controlAnnotation annotationLocation];
        
        CLLocationDistance newSearchRadius = [controlAnnotationLoc distanceFromLocation:[self.midPointAnnotation annotationLocation]];
        [view setDragState:MKAnnotationViewDragStateNone animated:YES];
        [self setSearchRadius:newSearchRadius];
        [self.midPointAnnotationView setVisible:YES animate:YES withNewFrame:self.searchRegionCGRect];
        [self setUpMidpointOverlap];
    }
    else if (newState == MKAnnotationViewDragStateStarting) {
        [controlAnnotation setHasBeenMoved:YES];
        [self.mapView bringSubviewToFront:controlView];
        [controlView startDragAnimation];
        self.searchRadiusControlDragState = MKAnnotationViewDragStateDragging;
    }
    else if (newState == MKAnnotationViewDragStateCanceling) {
        [controlView endDragAnimation];
        self.searchRadiusControlDragState = MKAnnotationViewDragStateNone;
        // tell the annotation view that the drag is done
        [view setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
}


#pragma mark Map Movement (MKMapviewDelegate Protocol)

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.midPointAnnotationView setVisible:NO animate:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.midPointAnnotationView setVisible:YES animate:YES withNewFrame:self.searchRegionCGRect];
}


#pragma mark Overlay View Renderers (MKMapviewDelegate Protocol)

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[CENContactMidpointOverlay class]]) {
        CENContactMidpointOverlayRenderer *view = [CENContactMidpointOverlayRenderer withOverlay:overlay
                                                                                 andOverlapRects:[self contactOverlapMapRects]];
        return view;
    }
    // else
    return nil;
}


#pragma mark - CENMapController Protocol Methods

-(void)addContactAnnotationForContact:(CENContact *)contact {
    if (!self.contactAnnotations) {
        _contactAnnotations = [[NSMutableArray alloc] init];
    }
    CENContactAnnotation *contactAnnotation = [CENContactAnnotation annotationForContact:contact];
    [self.mapView addAnnotation:contactAnnotation];
    [self.contactAnnotations addObject:contactAnnotation];
    [self.mapView showAnnotations:self.contactAnnotations animated:YES];
    [self setUpMidpointOverlap];
}

-(void)removeContactAnnotationForContact:(CENContact *)contact {
    for (CENContactAnnotation *contactAnnotation in self.contactAnnotations) {
        if ([contactAnnotation.contact isEqual:contact]) {
            [self.mapView removeAnnotation:contactAnnotation];
            [self.contactAnnotations removeObject:contactAnnotation];
            [self setUpMidpointOverlap];
        }
    }
}

-(void)removeAllAnnotation {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

-(void)removeSearchResults:(NSSet *)searchResults {
    NSSet *annotationsToRemove = [self searchResultsAnnotationsForResults:searchResults];
    [self.mapView removeAnnotations:[annotationsToRemove allObjects]];
    [self.searchResultAnnotations minusSet:annotationsToRemove];
}

-(void)removeAllSearchResults {
    NSArray *searchResultAnn = [self.searchResultAnnotations allObjects];
    [self.mapView removeAnnotations:searchResultAnn];
    [self.searchResultAnnotations removeAllObjects];
}

-(void)addSearchResults:(NSSet *)searchResults {
    NSSet *newResultAnnotations = [self searchResultsAnnotationsForResults:searchResults];
    if (!self.searchResultAnnotations) {
        self.searchResultAnnotations = [[NSMutableSet alloc] initWithSet:newResultAnnotations];
    }
    else {
        [self.searchResultAnnotations unionSet:newResultAnnotations];
    }
    [self.mapView addAnnotations:[newResultAnnotations allObjects]];
    [self.mapView showAnnotations:[self.searchResultAnnotations allObjects] animated:YES];
    NSLog(@"newAnnotationsCount: %lu currentAnnotationCount: %lu",newResultAnnotations.count,self.searchResultAnnotations.count);
}

-(NSSet *)searchResultsAnnotationsForResults:(NSSet *)searchResults {
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    for (CENSearchResult *result in searchResults) {
        [annotations addObject:[CENSearchResultAnnotation annotationForResult:result]];
    }
    return annotations;
}

#pragma mark - Notification Emmission

- (void)emitSearchRadiusChangedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENSearchRadiusChangedNotification object:nil];
}

- (void)emitMapRegionWillChangeNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:cnCENMapRegionWillChangeNotification
     object:[NSValue valueWithCGRect:[self searchRegionCGRect]]];
}

- (void)emitSearchRegionDidChangeNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:cnCENSearchRegionChangedNotification
     object:[CENCommon valueWithRegion:[self searchRegion]]];
}

- (void)emitETANeededNotificationForResult:(CENSearchResult *)result {
    MKDirectionsRequest *etaRequest = [[MKDirectionsRequest alloc] init];
    etaRequest.destination = result.mapItem;
    [[NSNotificationCenter defaultCenter] postNotificationName:cnCENETANeededForResultNotification
                                                        object:etaRequest];
}


#pragma mark - Notification Subscription

- (void)subscribeToNotifications {
    [self subscribeToLocationUpdatedNotification];
}


- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[CLLocation class]]) {
             CLLocation *userLocation = (CLLocation *)object;
             if (!self.userLocation) {
                 MKCoordinateRegion userRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate,
                                                                                    15000, 15000);
                 [self.mapView setRegion:userRegion animated:NO];
             }
             [self setUserLocation:userLocation];
         }
     }];
}


#pragma mark - Convenience Methods - Rect Geometry

- (BOOL)rectsWithinLeftBoundsForTabRect:(CGRect)tabRect
                          andTargetRect:(CGRect)targetRect {
    
    return tabRect.origin.x >= 0 && targetRect.origin.x <= 0;
}

- (BOOL)rectsWithinRightBoundsForTabRect:(CGRect)tabRect
                           andTargetRect:(CGRect)targetRect {
    
    CGFloat maxX = [self viewMaxX];
    BOOL isTabInBounds = CGRectGetMaxX(tabRect) <= maxX;
    BOOL isTargetInBounds = CGRectGetMinX(targetRect) <= maxX;
    return isTabInBounds && isTargetInBounds;
}

- (CGFloat)viewMaxX {
    return CGRectGetMaxX(self.view.frame);
}

#pragma mark - Convenience Methods - Circle Geometry

- (CLLocationDistance)distanceToMidpointForLocation:(CLLocation *)location {
    return [self.contactsMidpoint distanceFromLocation:location] + self.searchRadius;
}

- (MKCircle *)circleOverlappingMidpointFromLocation:(CLLocation *)location {
    CLLocationDistance circleRadius = [self distanceToMidpointForLocation:location];
    MKCircle *circle = [MKCircle circleWithCenterCoordinate:location.coordinate radius:circleRadius];
    return circle;
}

- (NSArray *)contactOverlapMapRects {
    NSMutableArray *mapRects = [[NSMutableArray alloc] init];
    for (CENContactAnnotation *contact in self.contactAnnotations) {
        CLLocation *location = [contact location];
        
        MKMapRect mapRect = [self mapRectOverlappingMidpointFromLocation:location];
        [mapRects addObject:[CENCommon valueWithMapRect:mapRect]];
    }
    
    return [NSArray arrayWithArray:mapRects];
}



- (MKMapRect)mapRectBoundingAllOverlapRegions {
    // Return a maprect that can contain all of the midpoint overlap circles.
    MKMapRect unionRect;
    for (CENContactAnnotation *contact in self.contactAnnotations) {
        CLLocation *location = [contact location];
        
        MKMapRect overlapRect = [self mapRectOverlappingMidpointFromLocation:location];
        
        unionRect = MKMapRectUnion(unionRect, overlapRect);
    }
    
    return unionRect;
}

-(MKMapRect)mapRectOverlappingMidpointFromLocation:(CLLocation *)location {
    MKCoordinateRegion overlapRegion = [self coordinateRegionOverlappingMidpointFromLocation:location];
    return MKMapRectForCoordinateRegion(overlapRegion);
}

-(MKCoordinateRegion)coordinateRegionOverlappingMidpointFromLocation:(CLLocation *)location {
    CLLocationDistance radius = [self distanceToMidpointForLocation:location]*2;
    return MKCoordinateRegionMakeWithDistance(location.coordinate, radius, radius);
}

#pragma mark - Convenience Methods - Drawer State Control

- (void)closeOppositeForTabViewGroup:(NSDictionary *)tabViewGroup {
    if ([tabViewGroup isEqual:self.searchPullTabViews]) {
        if ([self.contactPullTabViews[@"drawer visible"] isEqualToValue:@YES]) {
            [self hideTabViewGroup:self.contactPullTabViews];
        }
    }
    else {
        [self hideTabViewGroup:self.searchPullTabViews];
    }
}


#pragma mark - Geographic Midpoint Calculation

-(CLLocation *)contactsMidpoint {
    NSUInteger count = self.contactAnnotations.count;
    
    double tX = 0, tY = 0, tZ = 0;
    double avgX = 0, avgY = 0, avgZ = 0;
    
    for (CENContactAnnotation *contactAnnotation in self.contactAnnotations) {
        CLLocationCoordinate2D coordinate = contactAnnotation.location.coordinate;
        double lat = coordinate.latitude;
        double lng = coordinate.longitude;
        // degrees to radians
        lat = DegToRad(lat);
        lng = DegToRad(lng);
        // radian to cartesian coordinates
        double cX = cos(lat) * cos(lng);
        double cY = cos(lat) * sin(lng);
        double cZ = sin(lat);
        // add to running total of cartesian axis positions
        tX += cX;
        tY += cY;
        tZ += cZ;
    }
    
    // average cartesian position
    avgX = tX/count;
    avgY = tY/count;
    avgZ = tZ/count;
    // cartesian to radians
    double lng = atan2(avgY, avgX);
    double hyp = sqrt((avgX * avgX) + (avgY * avgY));
    double lat = atan2(avgZ, hyp);
    // radians to degrees
    lat = RadToDeg(lat);
    lng = RadToDeg(lng);
    
    return CLLocationMake(lat, lng);
}


#pragma mark - Map Coordinate to View Coordinate Translation

- (CGRect)searchRegionCGRect {
    MKCoordinateRegion searchRegion = [self searchRegion];
    CGRect searchRegionRect = [self.mapView convertRegion:searchRegion toRectToView:self.view];
    return searchRegionRect;
}

- (CLLocationCoordinate2D )searchRadiusControlCoordinate {
    // Calculate where to place the search radius control annotation
    MKMapRect searchAreaRect = MKMapRectForCoordinateRegion([self searchRegion]);
    MKMapPoint controlCenter = MKMapPointMake(MKMapRectGetMaxX(searchAreaRect), MKMapRectGetMaxY(searchAreaRect));
    CLLocationCoordinate2D controlCenterCoord = MKCoordinateForMapPoint(controlCenter);
    return controlCenterCoord;
}

- (CGPoint)overlapCenterPoint {
    return [self.mapView convertCoordinate:self.midPointAnnotation.coordinate toPointToView:self.mapView];
}

- (CGPoint)overlapCenterPointToView:(id)view {
    return [self.mapView convertCoordinate:self.midPointAnnotation.coordinate toPointToView:view];
}

- (MKCoordinateRegion)searchRegion {
    MKCoordinateRegion searchRegion = MKCoordinateRegionMakeWithDistance([self.midPointAnnotation coordinate],
                                                            self.searchRadius*2,
                                                            self.searchRadius*2);
    NSLog(@"searchRegion - lat: %f lng: %f distanceLat: %f distanceLng: %f",
          searchRegion.center.latitude,
          searchRegion.center.longitude,
          searchRegion.span.latitudeDelta,
          searchRegion.span.longitudeDelta);
    return searchRegion;
}


- (CGPoint)searchRegionCenterPoint {
    CLLocationCoordinate2D midpointCoordinate = self.midPointAnnotation.coordinate;
    return [self.mapView convertCoordinate:midpointCoordinate toPointToView:self.mapView];
}

- (CGRect)midpointOverlapRectForContactAnnotation:(CENContactAnnotation *)cAnnotation {
    CLLocationDistance distanceToCenter = [cAnnotation.location distanceFromLocation:[self.midPointAnnotation annotationLocation]];
    MKCoordinateRegion overlapRegion = MKCoordinateRegionMakeWithDistance(cAnnotation.coordinate,
                                                                          distanceToCenter,
                                                                          distanceToCenter);
    CGRect midpointOverlapRect = [self.mapView convertRegion:overlapRegion toRectToView:self.view];
    return midpointOverlapRect;
}



#pragma mark - Custom Setters

-(void)setSearchRadius:(CLLocationDistance)searchRadius {
    _searchRadius = searchRadius;
    [self emitSearchRadiusChangedNotification];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [CENCommon emitDismissSearchViewNotification];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.searchRadiusControlDragState == MKAnnotationViewDragStateDragging) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint touchPoint = [touch locationInView:self.view];
        CGPoint touchPointDest = [self.searchRadiusControlView convertPoint:touchPoint fromView:self.view];
        CGPoint overlapPoint = [self overlapCenterPointToView:self.searchRadiusControlView];
        [self.searchRadiusControlView
         updateWithTouchPoint:touchPointDest andOverlapPoint:overlapPoint];
    }
}

#pragma mark - Container Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segue: %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"Search View Segue"]) {
        self.searchViewController = (CENSearchViewController *)segue.destinationViewController;
        
    }
    else if ([segue.identifier isEqualToString:@"Contact View Segue"]) {
        [self setContactManager:[[CENContactManager alloc] init]];
        CENContactViewController *cvc = (CENContactViewController *)segue.destinationViewController;
        self.contactViewController = cvc;
        [cvc setContactManager:self.contactManager];
        
    }
    else if ([segue.identifier isEqualToString:@"travel info segue"]) {
        self.travelInfoViewController = (CENTravelInfoViewController *)segue.destinationViewController;
        [self.travelInfoViewController.view setBackgroundColor:[UIColor clearColor]];
        [self.view bringSubviewToFront:self.travelInfoViewController.view];
        
    }
}

#pragma mark - Container Visibility Control


@end
