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

@interface CENViewController () <MKMapViewDelegate,CENMapControllerProtocol>

@property (weak, nonatomic) IBOutlet CENMapView *mapView;

@property (weak, nonatomic) CENSearchViewController *searchViewController;
@property (weak, nonatomic) CENContactViewController *contactViewController;
@property (weak, nonatomic) UIView *searchPullTab;
@property (weak, nonatomic) UIView *contactPullTab;
@property (strong, nonatomic) NSMutableDictionary *searchPullTabViews;
@property (strong, nonatomic) NSMutableDictionary *contactPullTabViews;

@property (strong, nonatomic) CENLocationController *locationManager;
@property (strong, nonatomic) CENContactManager *contactManager;
@property (strong, nonatomic) CENMapController *mapController;

@property (strong, nonatomic) NSMutableArray *contactAnnotations;
@property (strong, nonatomic) NSMutableArray *searchResultAnnotations;
@property (strong, nonatomic) CENContactsMidpointAnnotation *midPointAnnotation;
@property (strong, nonatomic) CENSearchRadiusControlAnnotation *midPointSearchAreaHandleAnnotation;
@property (strong, nonatomic) CENContactMidpointAnnotationView *midPointAnnotationView;
@property (strong, nonatomic) CENSearchRadiusControlAnnotationView *searchAreaHandleView;

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
    [self setupSearchPullTab];
    [self setupContactPullTab];
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
    CGRect pullTabRect = CGRectMake(0, 428, 66, 66);
    UIView *pullTabView = [[UIView alloc] initWithFrame:pullTabRect];
    [pullTabView setBackgroundColor:[UIColor whiteColor]];
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
    CGRect pullTabRect = CGRectMake([self viewMaxX]-66, 360, 66, 66);
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
}

- (void)midpointOverlap {
    if (self.contactAnnotations.count > 1) {
        NSMutableArray *overlapCircles = [[NSMutableArray alloc] init];
        
        for (CENContactAnnotation *contactAnnotation in self.contactAnnotations) {
            MKCircle *circle = [self circleOverlappingMidpointFromLocation:contactAnnotation.location];
            [overlapCircles addObject:circle];
        }

        [self.mapView addOverlays:overlapCircles];
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
        [self.midPointSearchAreaHandleAnnotation setLocation:searchRadiusControlLoc];
    }
    else {
        CENSearchRadiusControlAnnotation *handle = [CENSearchRadiusControlAnnotation annotationWithLocation:searchRadiusControlLoc];
        [self setMidPointSearchAreaHandleAnnotation:handle];
        [self.mapView addAnnotation:self.midPointSearchAreaHandleAnnotation];
    }
    
    [self.midPointAnnotationView setNeedsDisplay];
    [self.searchAreaHandleView setNeedsDisplay];
}


#pragma mark - MKMapviewDelegate Protocol

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
        if (self.searchAreaHandleView) {
            [self.searchAreaHandleView setAnnotation:annotation];
        }
        else {
            self.searchAreaHandleView = [CENSearchRadiusControlAnnotationView withAnnotation:annotation andFrame:[self searchRegionCGRect]];
        }
        [self.searchAreaHandleView setCenterPoint:[self searchRegionCenterPoint]];
        return self.searchAreaHandleView;
    }
    
    
    // Contact Annotation View
    if ([annotation isKindOfClass:[CENContactAnnotation class]]) {
        MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CENContactAnnotation"];
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc] init];
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
    if (newState == MKAnnotationViewDragStateEnding) {
        CENSearchRadiusControlAnnotation *controlAnnotation = view.annotation;
        CLLocation *controlAnnotationLoc = [controlAnnotation annotationLocation];
        
        CLLocationDistance newSearchRadius = [controlAnnotationLoc distanceFromLocation:[self.midPointAnnotation annotationLocation]];
        [view setDragState:MKAnnotationViewDragStateNone animated:YES];
        [self setSearchRadius:newSearchRadius];
        [self.midPointAnnotationView setVisible:YES animate:YES withNewFrame:self.searchRegionCGRect];
        [self setUpMidpointOverlap];
    }
    else if (view.dragState == MKAnnotationViewDragStateDragging) {
    }
    
    else if (newState == MKAnnotationViewDragStateCanceling) {
        // custom code when drag canceled...
        
        // tell the annotation view that the drag is done
        [view setDragState:MKAnnotationViewDragStateNone animated:YES];
    }
}


#pragma mark Map Movement (MKMapviewDelegate Protocol)

-(void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [self.midPointAnnotationView setVisible:NO animate:YES];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self.searchAreaHandleView setCenterPoint:[self searchRegionCenterPoint]];
    [self.midPointAnnotationView setVisible:YES animate:YES withNewFrame:self.searchRegionCGRect];
}


#pragma mark Overlay View Renderers (MKMapviewDelegate Protocol)

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleRenderer *view = [[MKCircleRenderer alloc] initWithOverlay:overlay];
        view.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.08];
        view.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
        view.lineWidth = 1;
        
        return view;
    }
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
    // TODO
}

-(void)removeSearchResult:(MKPlacemark *)searchResult {
    //TODO
}

-(void)addSearchResult:(MKPlacemark *)searchResult {
    // TODO
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

- (void)emitMapRegionDidChangeNotification {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:cnCENMapRegionDidChangeNotification
     object:[NSValue valueWithCGRect:[self searchRegionCGRect]]];
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

#pragma mark - Container Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Search View Segue"]) {
        [self setSearchViewController:(CENSearchViewController *)segue.destinationViewController];
        
    }
    else if ([segue.identifier isEqualToString:@"Contact View Segue"]) {
        [self setContactManager:[[CENContactManager alloc] init]];
        CENContactViewController *cvc = (CENContactViewController *)segue.destinationViewController;
        [self setContactViewController:cvc];
        [cvc setContactManager:self.contactManager];
    }
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
    NSInteger count = self.contactAnnotations.count;
    
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

- (MKCoordinateRegion)searchRegion {
    return MKCoordinateRegionMakeWithDistance([self.midPointAnnotation coordinate],
                                              self.searchRadius*2,
                                              self.searchRadius*2);
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



@end
