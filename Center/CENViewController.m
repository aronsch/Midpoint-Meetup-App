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

@interface CENViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) CENSearchViewController *searchViewController;
@property (weak, nonatomic) CENContactViewController *contactViewController;
@property (weak, nonatomic) UIView *searchPullTab;
@property (weak, nonatomic) UIView *contactPullTab;
@property (strong, nonatomic) NSMutableDictionary *searchPullTabViews;
@property (strong, nonatomic) NSMutableDictionary *contactPullTabViews;

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
	// Do any additional setup after loading the view, typically from a nib.
//    [self.contactViewController.view setHidden:YES];
//    self.searchView.frame = CGRectOffset(self.searchView.frame, -400.0f, 0);
    [self setupSearchPullTab];
    [self setupContactPullTab];
}

#define ENDSCALE 0.0001f

-(void)viewtoFoldedPositionForView:(UIView *)view withDuration:(NSTimeInterval)duration {
    view.layer.anchorPoint = CGPointMake(0.0f, 0.5f);
    view.frame = CGRectOffset(view.frame, -view.frame.size.width/2, 0);
    [UIView animateWithDuration:duration
                     animations:^{
                         view.frame = CGRectOffset(view.frame, -view.frame.size.width, 0);
//                         view.transform = CGAffineTransformScale(view.transform, ENDSCALE, 1);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI Setup

- (void)setupSearchPullTab {
    CGRect pullTabRect = CGRectMake(0, 340, 66, 66);
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
    CGRect pullTabRect = CGRectMake([self viewMaxX]-66, 300, 66, 66);
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
    
    CGFloat xTranslation = [panGR translationInView:self.view].x;
    CGFloat xVelocity = [panGR velocityInView:self.view].x;
    
    UIView* tabView = tabViewGroup[@"tab"];
    UIView* targetView = tabViewGroup[@"target view"];
    
    CGRect tabNewFrame = CGRectOffset(tabView.frame, xTranslation, 0);
    CGRect targetNewFrame = CGRectOffset(targetView.frame, xTranslation, 0);
    
    // pan if tab is in view and outer edge of drawer
    // has not reached outer edge of view
    if ([tabViewGroup[@"side"] isEqualToString:@"left"]
        && [self rectsWithinLeftBoundsForTabRect:tabNewFrame andTargetRect:targetNewFrame]) {
            tabView.frame = tabNewFrame;
            targetView.frame = targetNewFrame;
    }
    else if ([tabViewGroup[@"side"] isEqualToString:@"right"]
             && [self rectsWithinRightBoundsForTabRect:tabNewFrame andTargetRect:targetNewFrame]) {
        
    }
    
    if ([panGR state] == UIGestureRecognizerStateEnded) {
        if (xVelocity > 0) { //panning right
            tabNewFrame.origin.x = targetNewFrame.size.width;
            targetNewFrame.origin.x = 0;
            [UIView animateWithDuration:0.15f
                             animations:^{
                                 [tabView setFrame:tabNewFrame];
                                 [targetView setFrame:targetNewFrame];
                             }
                             completion:^(BOOL finished){
                                 tabViewGroup[@"drawer visible"] = @YES;
                             }];
        }
        else if (xVelocity < 0) { //panning left
            tabNewFrame.origin.x = 0;
            targetNewFrame.origin.x = -targetNewFrame.size.width;
            [UIView animateWithDuration:0.15f
                             animations:^{
                                 [tabView setFrame:tabNewFrame];
                                 [targetView setFrame:targetNewFrame];
                             }
                             completion:^(BOOL finished){
                                 tabViewGroup[@"drawer visible"] = @NO;
                             }];
        }
    }
    
    
    [panGR setTranslation:CGPointZero inView:self.view];
}

#pragma mark Animation 

- (void)hideTabViewGroup:(NSMutableDictionary *)tabViewGroup {
    UIView *tabView = tabViewGroup[@"tab"];
    UIView *targetView = tabViewGroup[@"target view"];
    CGRect tabNewFrame = tabView.frame;
    CGRect targetNewFrame = targetView.frame;
    
    if ([tabViewGroup[@"side"] isEqualToString:@"left"]) {
        tabNewFrame.origin.x = 0;
        targetNewFrame.origin.x = -targetNewFrame.size.width;
        [UIView animateWithDuration:0.15f
                         animations:^{
                             [tabView setFrame:tabNewFrame];
                             [targetView setFrame:targetNewFrame];
                         }
                         completion:^(BOOL finished){
                             tabViewGroup[@"drawer visible"] = @NO;
                         }];
    }
    else if ([tabViewGroup[@"side"] isEqualToString:@"right"]) {
        tabNewFrame.origin.x = [self viewMaxX] - tabNewFrame.size.width;
        targetNewFrame.origin.x = [self viewMaxX];
        [UIView animateWithDuration:0.15f
                         animations:^{
                             [tabView setFrame:tabNewFrame];
                             [targetView setFrame:targetNewFrame];
                         }
                         completion:^(BOOL finished){
                             tabViewGroup[@"drawer visible"] = @NO;
                         }];
    }
}

- (void)showTabViewGroup:(NSMutableDictionary *)tabViewGroup {
    UIView *tabView = tabViewGroup[@"tab"];
    UIView *targetView = tabViewGroup[@"target view"];
    CGRect tabNewFrame = tabView.frame;
    CGRect targetNewFrame = targetView.frame;
    
    if ([tabViewGroup[@"side"] isEqualToString:@"left"]) {
        tabNewFrame.origin.x = targetNewFrame.size.width;
        targetNewFrame.origin.x = 0;
        [UIView animateWithDuration:0.15f
                         animations:^{
                             [tabView setFrame:tabNewFrame];
                             [targetView setFrame:targetNewFrame];
                         }
                         completion:^(BOOL finished){
                             tabViewGroup[@"drawer visible"] = @NO;
                         }];
    }
    else if ([tabViewGroup[@"side"] isEqualToString:@"right"]) {
        tabNewFrame.origin.x = [self viewMaxX] - targetNewFrame.size.width - tabNewFrame.size.width;
        targetNewFrame.origin.x = [self viewMaxX] - targetNewFrame.size.width;
        [UIView animateWithDuration:0.15f
                         animations:^{
                             [tabView setFrame:tabNewFrame];
                             [targetView setFrame:targetNewFrame];
                         }
                         completion:^(BOOL finished){
                             tabViewGroup[@"drawer visible"] = @NO;
                         }];
    }
}

#pragma mark Container Segues

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Search View Segue"]) {
        [self setSearchViewController:(CENSearchViewController *)segue.destinationViewController];
    }
    else if ([segue.identifier isEqualToString:@"Contact View Segue"]) {
        [self setContactViewController:(CENContactViewController *)segue.destinationViewController];
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

@end
