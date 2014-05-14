
//
//  CENSearchViewController.m
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchViewController.h"
#import "CENSearchManager.h"
#import "CENCommon.h"

@interface CENSearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CENSearchManager *searchController;
@property (nonatomic) CGRect frameFullSize;
@property (nonatomic) BOOL isMinified;

@property (weak, nonatomic) IBOutlet UITextField *userKeywordSearchTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *priceFilterSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *overlapAmountSegmentControl;
@property (weak, nonatomic) IBOutlet UITableView *placeTypesTable;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@end

@implementation CENSearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configure];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }
    [self configure];
    return self;
}

-(void)configure {
    self.searchController = [[CENSearchManager alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self subscribeToDismissSearchViewNotification];
    
    _frameFullSize = CGRectMake(0, 0, 252, 403);
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewTap:)];
    [self.view addGestureRecognizer:tapGR];
    
    UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleViewDoubleTap:)];
    doubleTapGR.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGR];
    self.view.layer.cornerRadius = 10.0f;
}

-(void)viewWillAppear:(BOOL)animated {
    self.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f];
    [self minifyImmediately];
}

#pragma mark - Tap Gesture Handling

- (void)handleViewTap:(UITapGestureRecognizer *)tapGR {
    if (tapGR.state == UIGestureRecognizerStateEnded) {
        if (self.isMinified) {
            self.isMinified = NO;
        }
    }
}

- (void)handleViewDoubleTap:(UITapGestureRecognizer *)tapGR {
    if (tapGR.state == UIGestureRecognizerStateEnded) {
        if (self.isMinified) {
            self.isMinified = NO;
            [self.userKeywordSearchTextField becomeFirstResponder];
        }
    }
}

#pragma mark - Handle Interaction

- (IBAction)userSearchKeywordEntered:(UITextField *)sender {
    [sender resignFirstResponder];
    [self.searchController setUserKeyword:sender.text];
}

- (IBAction)userSearchKeywordExited:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)touchOutsideUserKeywordField:(UITextField *)sender {
    if (sender.editing) {
        [self.view endEditing:YES];
        [sender resignFirstResponder];
    }
}

- (IBAction)priceRangeChanged:(UISegmentedControl *)sender {
    int selected = (int)sender.selectedSegmentIndex;
    [self.searchController
     setPriceOption:(COAPriceOption)selected];
}

- (IBAction)overlapAllowanceChanged:(UISegmentedControl *)sender {
    int selected = (int)sender.selectedSegmentIndex;
    [self.searchController setOverlapOption:(COAOverlapOption)selected];
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    self.isMinified = YES;
    [self.searchController search];
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchController setPlaceTypesSelected:tableView.indexPathsForSelectedRows];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchController setPlaceTypesSelected:tableView.indexPathsForSelectedRows];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.searchController.placeTypes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Type Cell"];
    cell.textLabel.text = self.searchController.placeTypes[(NSUInteger)indexPath.item];
    return cell;
}


#pragma mark - View Minification Methods

-(void)setIsMinified:(BOOL)isMinified {
    _isMinified = isMinified;
    if (isMinified) {
        [self minify];
    }
    else {
        [self expand];
    }
}

#define transition_duration 0.2f

- (void)minify {
    [self minifyWithDuration:transition_duration];
}

- (void)minifyImmediately {
    [self minifyWithDuration:0];
}

- (void)expand {
    [self expandWithDuration:transition_duration];
}

- (void)expandImmediately {
    [self expandWithDuration:0];
}

- (void)minifyWithDuration:(NSTimeInterval)duration {
    self.userKeywordSearchTextField.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:duration*2 animations:^{
        CAAnimation *frameAnim = [CAAnimation animation];

        [frameAnim setValue:[NSValue valueWithCGRect:[self frameMinified]] forKeyPath:@"frame"];
        frameAnim.duration = duration;
        frameAnim.beginTime = 0.05f;
        frameAnim.fillMode = kCAFillModeForwards;
        frameAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimation *backgroundAnim = [CAAnimation animation];
        NSValue *colorValue = [NSValue
                               value:[[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor
                               withObjCType:@encode(CGColorRef)];
        [backgroundAnim setValue:colorValue forKeyPath:@"backgroundColor"];
        backgroundAnim.duration = duration;
        backgroundAnim.beginTime = duration;
        backgroundAnim.fillMode = kCAFillModeForwards;
        backgroundAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimation *opacityAnim = [CAAnimation animation];
        [frameAnim setValue:@0.0 forKeyPath:@"opacity"];
        opacityAnim.duration = duration/3;
        opacityAnim.beginTime = 0.0f;
        opacityAnim.fillMode = kCAFillModeForwards;
        
        // views have fade start time offset based array order
        NSArray *viewsToFade = @[self.searchButton,
                                 self.placeTypesTable,
                                 self.overlapAmountSegmentControl,
                                 self.priceFilterSegmentControl];
        
        // add animations
        [self.view.layer addAnimation:frameAnim forKey:@"frame"];
        [self.view.layer addAnimation:backgroundAnim forKey:@"backgroundColor"];
        for (UIView *view in viewsToFade) {
            [view.layer addAnimation:opacityAnim forKey:@"frame"];
            view.layer.opacity = 0.0f;
            opacityAnim.beginTime += duration/8;
        }
        self.view.frame = [self frameMinified];
        self.view.layer.cornerRadius = 10.0f;
    }];
    _isMinified = YES;
    self.view.layer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0f].CGColor;
}

- (void)expandWithDuration:(NSTimeInterval)duration {
    self.userKeywordSearchTextField.userInteractionEnabled = YES;
    [UIView animateWithDuration:duration*2 animations:^{
        CAAnimation *frameAnim = [CAAnimation animation];
        [frameAnim setValue:[NSValue valueWithCGRect:self.frameFullSize] forKeyPath:@"frame"];
        frameAnim.duration = duration;
        frameAnim.beginTime = 0.05f;
        frameAnim.fillMode = kCAFillModeForwards;
        frameAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimation *backgroundAnim = [CAAnimation animation];
        NSValue *colorValue = [NSValue
                              value:[[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor
                              withObjCType:@encode(CGColorRef)];
        [backgroundAnim setValue:colorValue forKeyPath:@"backgroundColor"];
        backgroundAnim.duration = duration;
        backgroundAnim.beginTime = 0.0;
        backgroundAnim.fillMode = kCAFillModeForwards;
        backgroundAnim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimation *opacityAnim = [CAAnimation animation];
        [frameAnim setValue:@1.0 forKeyPath:@"opacity"];
        opacityAnim.duration = duration/4;
        opacityAnim.beginTime = 0.0f;
        opacityAnim.fillMode = kCAFillModeForwards;
        
        // views have fade start time offset based array order
        NSArray *viewsToFade = @[self.priceFilterSegmentControl,
                                 self.overlapAmountSegmentControl,
                                 self.placeTypesTable,
                                 self.searchButton];
        
        // add animations
        [self.view.layer addAnimation:frameAnim forKey:@"frame"];
        [self.view.layer addAnimation:backgroundAnim forKey:@"backgroundColor"];
        for (UIView *view in viewsToFade) {
            [view.layer addAnimation:opacityAnim forKey:nil];
            opacityAnim.beginTime += duration/8;
            view.layer.opacity = 1.0f;
        }
        self.view.frame = self.frameFullSize;
        self.view.layer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1.0f].CGColor;
        self.view.layer.cornerRadius = 10.0f;
    }];
    _isMinified = NO;
}

- (CGRect)frameMinified {
    CGFloat frameTopY = CGRectGetMinY(self.frameFullSize);
    CGFloat searchBoxBottomY = CGRectGetMaxY(self.userKeywordSearchTextField.frame);
    CGFloat frameHeight = searchBoxBottomY - frameTopY;
    CGRect minifiedFrame = CGRectMake(self.view.frame.origin.x,
                                      self.view.frame.origin.y,
                                      self.view.frame.size.width,
                                      frameHeight+10);
    return minifiedFrame;
}

#pragma mark - Notification Subscription

- (void)subscribeToDismissSearchViewNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENDismissSearchViewNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         self.isMinified = YES;
     }];
}
@end
