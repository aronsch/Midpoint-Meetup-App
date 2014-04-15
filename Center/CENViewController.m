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
#import "CENLocationManager.h"
#import "CENContactManager.h"
#import "CENCommon.h"

@interface CENViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) CENSearchViewController *searchViewController;
@property (weak, nonatomic) CENContactViewController *contactViewController;
@property (weak, nonatomic) UIView *searchPullTab;
@property (weak, nonatomic) UIView *contactPullTab;
@property (strong, nonatomic) NSMutableDictionary *searchPullTabViews;
@property (strong, nonatomic) NSMutableDictionary *contactPullTabViews;


@property (strong, nonatomic) CENLocationManager *locationManager;
@property (strong, nonatomic) CENContactManager *contactManager;

@property (strong, nonatomic) NSMutableArray *contactLocationDicts;

typedef enum {
    kPanLeft,
    kPanRight,
    kNoPan
} CENPanDirection;

@end

@implementation CENViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configure];
}

- (void)configure {
    [self setupSearchPullTab];
    [self setupContactPullTab];
    [self setLocationManager:[[CENLocationManager alloc] init]];
    [self.locationManager beginUpdatingLocation];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI Setup

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

#pragma mark UI Animation

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

#pragma mark - Notification Subscription

#pragma mark Notifications

- (void)subscribeToLocationUpdatedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENUserLocationUpdatedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         //
     }];
}

- (void)subscribeToContactAddedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nCENContactAddedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         // TODO: Location and Contact Dict
     }];
}

#pragma mark - Contact Handling

-(NSMutableDictionary *)contactLocationDictionaryForContact:(CENContact *)contact {
    return [NSMutableDictionary dictionaryWithDictionary:@{@"contact": contact,
                                                           @"location": [[CLLocation alloc] init]}];
}

- (void)addContactLocationForContact:(CENContact *)contact {
    [self.contactLocationDicts addObject:[self contactLocationDictionaryForContact:contact]];
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

#pragma mark - Utility

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

@end
