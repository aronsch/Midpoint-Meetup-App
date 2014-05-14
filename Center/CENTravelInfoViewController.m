//
//  CENTravelInfoViewController.m
//  Center
//
//  Created by Aron Schneider on 4/10/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENTravelInfoViewController.h"
#import "CENCommon.h"
#import "CENContactInfoCVCell.h"
#import "CENAddContactCVCell.h"
#import "CENViewController.h"
@import QuartzCore;

@interface CENTravelInfoViewController () <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *contactsCollectionView;
@property (nonatomic) CENContact *selectedContact;
@property (strong, nonatomic) NSArray *contacts;

@end

@implementation CENTravelInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.view setOpaque:NO];
        [self.view setBackgroundColor:[UIColor clearColor]];
        [self.contactsCollectionView setOpaque:NO];
        [self.contactsCollectionView setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self subscribeToContactsChangedNotification];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
 sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeZero;
    if (indexPath.section == 0 && self.contacts.count <= 5) {
        size = CGSizeMake(100, 88);
    }
    if (indexPath.section == 0 && self.contacts.count > 5) {
        size = CGSizeMake(75, 66);
    }
    else if (indexPath.section == 1) {
        size = CGSizeMake(72, 88);
    }
    return size;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = (NSInteger)self.contacts.count;
    }
    if (section == 1) {
        count = 1;
    }
    return count;
}

-(id)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    id cell;
    if (indexPath.section == 1) {
        cell = [collectionView
                                      dequeueReusableCellWithReuseIdentifier:crCENAddContactCVCellReuseID
                                      forIndexPath:indexPath];
    }
    else if (indexPath.section == 0){
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:crCENContactInfoCVCellReuseID
                                                         forIndexPath:indexPath];
        CENContact *contact = [self.contacts objectAtIndex:(NSUInteger)indexPath.item];
        
        [cell setContact:contact];
        [cell setClipsToBounds:NO];
    }
    return cell;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.contactsCollectionView cellForItemAtIndexPath:indexPath];
    if (cell.reuseIdentifier == crCENContactInfoCVCellReuseID) {
        CENContactInfoCVCell *contactCell = (CENContactInfoCVCell *)cell;
        self.selectedContact = contactCell.contact;
    }
    else if (cell.reuseIdentifier == crCENAddContactCVCellReuseID) {
        if ([self.parentViewController isKindOfClass:[CENViewController class]]) {
            CENViewController *pVC = (CENViewController *)self.parentViewController;
            [pVC presentContactPicker];
        }
    }
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [self.contactsCollectionView cellForItemAtIndexPath:indexPath];
    if (cell.reuseIdentifier == crCENContactInfoCVCellReuseID) {
        CENContactInfoCVCell *contactCell = (CENContactInfoCVCell *)cell;
        if (contactCell.contact == self.selectedContact) {
            self.selectedContact = nil;
        }
    }
}



#pragma mark - Notification Subscription

- (void)subscribeToContactsChangedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENContactsHaveChangedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[NSArray class]]) {
             [self setContacts:object];
         }
         else {
             [CENCommon exceptionPayloadClassExpected:[NSArray class]
                               forNotification:notification];
         }
     }];
}

#pragma mark - Dismiss Other View Controllers on Touch
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [CENCommon emitDismissSearchViewNotification];
}

#pragma mark - Custom Setters

-(void)setContacts:(NSArray *)contacts {
    _contacts = contacts;
    [self.contactsCollectionView reloadData];
}

@end
