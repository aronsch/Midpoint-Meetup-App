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
@property (strong, nonatomic) NSDictionary *searchPullTabViews;

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

- (void)setupSearchPullTab {
    CGRect pullTabRect = CGRectMake(0, 300, 66, 66);
    UIView *pullTab = [[UIView alloc] initWithFrame:pullTabRect];
    [pullTab setBackgroundColor:[UIColor whiteColor]];
    [self setSearchPullTab:pullTab];
    [self setSearchPullTabViews:@{@"tab": pullTab,
                                  @"target view": self.searchViewController.view.superview,
                                  @"side": @"left"}];
    
    [self.view addSubview:pullTab];
    [self.view bringSubviewToFront:pullTab];
    [self configurePanGestureRecognizers];
}

- (void)configurePanGestureRecognizers {
    UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftDrawerPan:)];
    
    [self.searchViewController.view addGestureRecognizer:panGR];
    [self.searchPullTab addGestureRecognizer:panGR];
    
}

- (void)offsetTabViewGroup:(NSDictionary *)tabViewGroup
                                      xOffset:(CGFloat)xOffset
{
    UIView* tabView = tabViewGroup[@"tab"];
    UIView* targetView = tabViewGroup[@"target view"];
    
    CGRect tabNewFrame = CGRectOffset(tabView.frame, xOffset, 0);
    CGRect targetNewFrame = CGRectOffset(targetView.frame, xOffset, 0);
    
    if (tabNewFrame.origin.x >= 0 &&
        targetNewFrame.origin.x <= 0){
        NSLog(@"target x origin: %f // tab x origin: %f",
              targetNewFrame.origin.x,
              tabNewFrame.origin.x);
        tabView.frame = tabNewFrame;
        targetView.frame = targetNewFrame;
    }
    
}

- (void)handleLeftDrawerPan:(UIPanGestureRecognizer *)panGR {
    UIView *selfView = self.view;
//    UIView *tabView = self.searchPullTabViews[@"tab"];
//    UIView *drawerView = self.searchPullTabViews[@"target view"];
    CGFloat xTranslation = [panGR translationInView:selfView].x;
    CGFloat xVelocity = [panGR velocityInView:selfView].x;
    [self.view bringSubviewToFront:self.searchViewController.view];
    [self offsetTabViewGroup:self.searchPullTabViews xOffset:xTranslation];
    [panGR setTranslation:CGPointZero inView:selfView];
    
//    
//    CENPanDirection direction = [self panDirectionForTranslation:xVelocity];
//    
//    CGFloat drawerWidth = self.searchViewController.view.frame.size.width;
//    
//    CGRect newFrame = CGRectOffset(selfView.frame, xTranslation, 0);
//    
//    if (newFrame.origin.x > 0) {
//        newFrame.origin.x = 0;
//    }
//    if (newFrame.origin.x < -drawerWidth) {
//        newFrame.origin.x = -drawerWidth;
//    }
//    
//    if ([panGR state] == UIGestureRecognizerStateEnded) {
//        switch (direction) {
//            case kPanRight:
//                if (xVelocity > 0 || selfView.origin.x > -drawerWidth/2) {
//                    newFrame.origin.x = 0;
//                    [UIView animateWithDuration:0.15f
//                                     animations:^{
//                                         [drawerView setFrame:newFrame];
//                                     }
//                                     completion:^(BOOL finished){
//                                     }];
//                }
//                break;
//            case kPanLeft:
//                if (xVelocity < 0 || drawerView.frame.origin.x < -drawerWidth/2) {
//                    newFrame.origin.x = -drawerWidth;
//                    [UIView animateWithDuration:0.15f
//                                     animations:^{
//                                         [drawerView setFrame:newFrame];
//                                     }
//                                     completion:^(BOOL finished){
//                                     }];
//                }
//                break;
//            case kNoPan:
//                break;
//            default:
//                break;
//        }
//    }
//    
//    self.frame = newFrame;
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

- (CENPanDirection)panDirectionForTranslation:(CGFloat)xTranslation {
    CENPanDirection direction;
    if (xTranslation > 0) {
        direction = kPanRight;
    }
    else if (xTranslation < 0) {
        direction = kPanLeft;
    }
    else {
        direction = kNoPan;
    }
    return direction;
}

@end
