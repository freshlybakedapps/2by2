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
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) NSArray *friends;
@end


@implementation FindContactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Contacts";
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor appGrayColor],
                                                           NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                           }];

    
    [self.tableView registerNib:[UINib nibWithNibName:@"FindFacebookFriendsCell" bundle:nil] forCellReuseIdentifier:@"FindFacebookFriendsCell"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont appFontOfSize:18], NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = normalAttributes;
    
    [self findFriendsFromContacts];
}

- (void)findFriendsFromContacts
{
    CFErrorRef error;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted) {
                //TODO: handle error
            }
            else {
                [self parseAddressBook:addressBook];
            }
            CFRelease(addressBook);
        });
    });
}

- (void)parseAddressBook:(ABAddressBookRef)addressBook
{
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(addressBook);
    NSMutableArray *uniqueEmails = [NSMutableArray array];
    
    for (int i = 0; i < numberOfContacts; i++) {
        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
        NSArray *emailArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailProperty));
        CFRelease(emailProperty);
        
        if (emailArray.count) {
            NSString *email = [emailArray componentsJoinedByString:@"\n"];
            if (![uniqueEmails containsObject:email]){
                [uniqueEmails addObject:email];
            }
        }
    }
    CFRelease(allContacts);
    
    NSLog(@"uniqueEmails: %lu",(unsigned long)uniqueEmails.count);

    self.statusLabel.text = [NSString stringWithFormat:@"Checking %lu contacts...", (unsigned long)uniqueEmails.count];

    [PFCloud callFunctionInBackground:@"getContactFriends"
                       withParameters:@{@"contacts":uniqueEmails, PFUserIDKey:[PFUser currentUser].objectId}
                                block:^(NSArray *result, NSError *error) {
                                    if (!error) {
                                        self.statusLabel.text = [NSString stringWithFormat:@"Found %lu friends", (unsigned long)result.count];
                                        self.friends = result;
                                        NSLog(@"%@",result);
                                        [self.tableView reloadData];
                                    }
                                    else {
                                        NSLog(@"getContactFriends error: %@", error);
                                        self.statusLabel.text = [NSString stringWithFormat:@"Error loading friends"];
                                    }
                                }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindFacebookFriendsCell" forIndexPath:indexPath];
    
    cell.data = [self.friends objectAtIndex:indexPath.row];
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;

}


@end
