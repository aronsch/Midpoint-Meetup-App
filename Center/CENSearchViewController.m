//
//  CENSearchViewController.m
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENSearchViewController.h"
#import "CENSearchManager.h"

@interface CENSearchViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) CENSearchManager *searchController;

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

-(void)configure {
    self.searchController = [[CENSearchManager alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Handle Interaction

- (IBAction)userSearchKeywordEntered:(UITextField *)sender {
    [sender resignFirstResponder];
    [self.searchController setUserKeyword:sender.text];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.searchController.placeTypes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place Type Cell"];
    cell.textLabel.text = self.searchController.placeTypes[(NSUInteger)indexPath.item];
    return cell;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
