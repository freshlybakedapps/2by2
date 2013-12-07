//
//  FindInviteFriendsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/30/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FindInviteFriendsViewController.h"
#import "FindFacebookFriendsViewController.h"
#import "FindContactsViewController.h"



@interface FindInviteFriendsViewController ()

@end

@implementation FindInviteFriendsViewController

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
    self.navigationItem.title = @"Finding friends";
    
    self.sections = [NSMutableArray new];
    [self.sections addObject:@"Find Facebook Friends"];
    [self.sections addObject:@"From Your Contacts"];
    [self.sections addObject:@"Invite Friends"];
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
    return self.sections.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }
    
    cell.textLabel.text = [self.sections objectAtIndex:indexPath.row];
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        FindFacebookFriendsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FindFacebookFriendsViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }else if(indexPath.row == 1){
        FindContactsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FindContactsViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }else if(indexPath.row == 2){
        
        //http://agilewarrior.wordpress.com/2012/02/01/how-to-access-the-address-book-ios/
        
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        
        [self presentViewController:picker animated:YES completion:^{
            //
        }];
    }
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)aPerson {
    
    ABMultiValueRef fnameProperty = ABRecordCopyValue(aPerson, kABPersonFirstNameProperty);
    ABMultiValueRef lnameProperty = ABRecordCopyValue(aPerson, kABPersonLastNameProperty);
    ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);
    ABMultiValueRef phoneProperty = ABRecordCopyValue(aPerson, kABPersonPhoneProperty);
    
    NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);
    
    NSArray *phoneArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(phoneProperty);
    
    NSString* name;
    NSString* email;
    NSString* phone;
    
    if (fnameProperty != nil) {
        name = [NSString stringWithFormat:@"%@", fnameProperty];
    }
    if (lnameProperty != nil) {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
    }
    if ([emailArray count] > 0) {
        email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
    }
    if ([phoneArray count] > 0) {
        phone = [NSString stringWithFormat:@"%@", [phoneArray objectAtIndex:0]];
    }
    
    NSString *msg = [NSString stringWithFormat:@"Inviting %@ to 2by2",name];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(email && phone){
            UIAlertView *alert = [UIAlertView alertViewWithTitle:nil message:msg];
            [alert setCancelButtonWithTitle:@"BY EMAIL" handler:^{
                [self sendEmail:email];
            }];
            [alert setCancelButtonWithTitle:@"BY TEXT" handler:^{
                [self sendSMS:msg recipientList:@[phone]];
            }];
            [alert show];
            
            
        }else if(email){
            [self sendEmail:email];
        }else if(phone){
            [self sendSMS:msg recipientList:@[phone]];
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry that contact didn't contain any email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    return NO;
}

-(void)sendEmail:(NSString*)email {
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:@"Check out my photos on 2by2"];
        [mailCont setToRecipients:[NSArray arrayWithObject:email]];
        [mailCont setMessageBody:@"I am inviting you yo check out my photos on 2by2. <a href='http://2by2.parseapp.com'>Download the app, it's tottally free!</a>" isHTML:YES];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled){
        NSLog(@"Message cancelled");
    }else if (result == MessageComposeResultSent){
            NSLog(@"Message sent");
    }else{
        NSLog(@"Message failed");
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
