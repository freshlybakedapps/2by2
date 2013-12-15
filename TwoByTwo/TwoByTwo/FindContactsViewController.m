//
//  FindContactsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/1/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FindContactsViewController.h"
#import "FindFacebookFriendCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface FindContactsViewController ()

@end

@implementation FindContactsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Contacts";
    [self findFriendsFromContacts];
}

- (void) findFriendsFromContacts{
    NSMutableArray* arr = [NSMutableArray new];
    
    
    ABAddressBookRef allPeople;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0){
        allPeople = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(allPeople,
                                                 ^(bool granted, CFErrorRef error){
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        //dispatch_release(sema);
    }
    else {
        CFErrorRef error = NULL;
        allPeople = ABAddressBookCreateWithOptions(NULL, &error);
    }
    
    
    
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);
    
    //NSLog(@"numberOfContacts------------------------------------%ld",numberOfContacts);
    
    
    for(int i = 0; i < numberOfContacts; i++){
        //NSMutableDictionary *dic = [NSMutableDictionary new];
        //NSString* name = @"";
        NSString* email = @"";
        
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        //ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
        //ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
        
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        
        NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
        
        /*
        if (fnameProperty != nil) {
            name = [NSString stringWithFormat:@"%@", fnameProperty];
        }
        if (lnameProperty != nil) {
            name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        }
        */
        
        
        if ([emailArray count] > 0) {
            
             if ([emailArray count] > 1) {
                 for (int i = 0; i < [emailArray count]; i++) {
                     email = [email stringByAppendingString:[NSString stringWithFormat:@"%@\n", [emailArray objectAtIndex:i]]];
                 }
             }else {
                 email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
             }
            
            //only add unique email addresses
            if (![arr containsObject:email]){
                [arr addObject:email];
            }
        }
        
    }
    
    
    [PFCloud callFunctionInBackground:@"getContactFriends"
                       withParameters:@{@"contacts":arr,@"userID":[PFUser currentUser].objectId}
                                block:^(NSArray *result, NSError *error) {
                                    if (!error) {
                                        //NSLog(@"friends: %@", result);
                                        self.friends = result;
                                        [self.tableView reloadData];

                                    }
                                }];
    
    NSString* msg = [NSString stringWithFormat:@"You have %ld unique email addresses out of %ld contacts...please wait",(unsigned long)arr.count,numberOfContacts];
    
    [[[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindFacebookFriendCell" forIndexPath:indexPath];
    
    cell.data = [self.friends objectAtIndex:indexPath.row];
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;

}


@end
