//
//  CENContactViewController.m
//  Center
//
//  Created by Aron Schneider on 4/6/14.
//  Copyright (c) 2014 Aron Schneider. All rights reserved.
//

#import "CENContactViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CENContactManager.h"
#import "CENContact.h"
#import "CENContactViewTableViewCell.h"

@interface CENContactViewController () <UITableViewDataSource,UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, assign) ABAddressBookRef addressBook;
@property (nonatomic, strong) CENContactManager *contactManager;
@property (strong, nonatomic) IBOutlet UITableView *contactTableView;

@end

@implementation CENContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self subscribeToNofications];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


#pragma mark Contact Add Button

- (IBAction)addContact:(UIButton *)sender {
    [self showPeoplePickerController];
}

-(void)presentContactPicker {
    [self showPeoplePickerController];
}

#pragma mark Show ABPeoplePickerNavigationController
-(void)showPeoplePickerController
{
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
	NSArray *displayedItems = @[[NSNumber numberWithInt:kABPersonAddressProperty],
                                [NSNumber numberWithInt:kABPersonImageFormatThumbnail]];
	
	picker.displayedProperties = displayedItems;
    
	// Show the picker
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark ABPeoplePickerNavigationController

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    __block CENContactViewController *blockSelf = self;
    
    CENContactABInfo abInfo = CENContactABInfoMake(person, property, identifier);
    
    [self.contactManager addContactWithCENContactABInfo:abInfo
                                        completionBlock:^(CENContactAddStatus status, CENContact *contact){
                                            switch (status) {
                                                case kFailedContactExists:
                                                    [blockSelf displayContactExistsAlertForContact:contact];
                                                    break;
                                                case kContactAddSuccess:
                                                    [blockSelf contactAdded];
                                                    break;
                                                default:
                                                    break;
                                            }
                                        }];
	return NO;
}

- (void)displayContactExistsAlertForContact:(CENContact *)contact {
    NSString *firstName = contact.firstName;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Already Added"
                                                    message:[NSString
                                                             stringWithFormat:@"Looks like %@ has already been added!",
                                                             firstName]
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
}

- (void)contactAdded {
    [self.contactTableView reloadData];
}

// Dismisses the people picker and shows the application when users tap Cancel.
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    [peoplePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Address Book Access

-(void)checkAddressBookAccess
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined :
            [self requestAddressBookAccess];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning"
                                                            message:@"Permission was not granted for Contacts."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

-(void)requestAddressBookAccess
{
    CENContactViewController * __block blockSelf = self;
    
    ABAddressBookRequestAccessWithCompletion(self.addressBook,
                                             ^(bool granted, CFErrorRef error) {
                                                 if (granted)
                                                 {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         [blockSelf accessGrantedForAddressBook];
                                                     });
                                                 }
                                             });
}


-(void)accessGrantedForAddressBook
{
    
}

#pragma mark - UITableViewDataSource Protocol

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (NSInteger)self.contactManager.contacts.count;
}

-(CENContactViewTableViewCell *)tableView:(UITableView *)tableView
                    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CENContactViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cCENContactCellReuseID];
    
    CENContact *contact = [self.contactManager contactAtIndex:(NSUInteger)indexPath.item];
    [cell setName:[contact nameFirstLast]];
    [cell setAddress:[contact addressAsMultiLineString]];
    [cell setContactPhoto:[contact contactPhoto]];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        CENContact *contact = [self.contactManager contactAtIndex:(NSUInteger)indexPath.item];
        [self.contactManager removeContact:contact];
        
        [self.contactTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }
}


#pragma mark - Notification Handling

- (void)subscribeToNofications {
    [self subscribeToContactAddedNotification];
}

- (void)subscribeToContactAddedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENContactAddedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         [self.contactTableView reloadData];
     }];
}

- (void)subscribeToContactRemovedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENContactRemovedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         [self.contactTableView reloadData];
     }];
}

- (void)subscribeToContactUpdateRequestedNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:cnCENContactUpdateRequestedNotification
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *notification)
     {
         id object = notification.object;
         if ([object isKindOfClass:[CENContact class]]) {
             CENContact *contact = (CENContact *)object;
             ABRecordRef record = ABAddressBookGetPersonWithRecordID(self.addressBook, [contact.contactID intValue]);
             [contact updateWithInfo:CENContactABInfoMake(record,
                                                          [contact addressBookInfo].property,
                                                          [contact addressBookInfo].identifier)];
         }
     }];
}



@end
