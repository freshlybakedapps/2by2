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
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface FindInviteFriendsViewController () <ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic, weak) IBOutlet UITableViewCell *inviteCell;
@end


@implementation FindInviteFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Finding friends";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.inviteCell) {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        [self presentViewController:picker animated:YES completion:nil];
    }
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef fnameProperty = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    ABMultiValueRef lnameProperty = ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
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
        email = [NSString stringWithFormat:@"%@", emailArray[0]];
    }
    if ([phoneArray count] > 0) {
        phone = [NSString stringWithFormat:@"%@", phoneArray[0]];
    }
    
    NSString *msg = [NSString stringWithFormat:@"Inviting %@ to 2by2", name];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (email && phone) {
            UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:msg];
            [alert bk_addButtonWithTitle:@"BY EMAIL" handler:^{
                [self sendEmail:email];
            }];
            [alert bk_addButtonWithTitle:@"BY TEXT" handler:^{
                [self sendSMS:msg recipientList:@[phone]];
            }];
            [alert bk_setCancelButtonWithTitle:@"CANCEL" handler:^{
                //cancel
            }];
            [alert show];
        }
        else if(email) {
            [self sendEmail:email];
        }
        else if(phone) {
            [self sendSMS:msg recipientList:@[phone]];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry that contact didn't contain any email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    return NO;
}

- (void)sendEmail:(NSString *)email
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        [controller setSubject:@"Check out my photos on 2by2"];
        [controller setToRecipients:@[email]];
        [controller setMessageBody:@"I am inviting you yo check out my photos on 2by2. <a href='http://2by2.parseapp.com'>Download the app, it's tottally free!</a>" isHTML:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        controller.recipients = recipients;
        controller.body = bodyOfMessage;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent) {
        NSLog(@"Message sent");
    
    }
    else {
        NSLog(@"Message failed");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
