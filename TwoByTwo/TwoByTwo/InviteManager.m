//
//  InviteManager.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "InviteManager.h"
#import "MainViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <FacebookSDK.h>


@interface InviteManager () <ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end


@implementation InviteManager

+ (instancetype)sharedInstance
{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    return _sharedInstance;
}

- (void)inviteByEmail
{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [[MainViewController currentController] presentViewController:picker animated:YES completion:nil];
}

- (void)inviteByFacebook
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Hey, inviting you to check out my pics on 2by2, join and we can make double exposures together. Download the app here: https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8"
                                                    title:@"2by2!"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      }
                                                      else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          }
                                                          else {
                                                              NSLog(@"Request Sent. %@",resultURL);
                                                          }
                                                      }
                                                  }
                                              friendCache:nil];
}


#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [[MainViewController currentController] dismissViewControllerAnimated:YES completion:nil];
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
    
    NSArray *emailArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailProperty));
    CFRelease(emailProperty);
    
    NSArray *phoneArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneProperty));
    CFRelease(phoneProperty);
    
    NSString* name;
    NSString* email;
    NSString* phone;
    
    if (fnameProperty != nil) {
        name = [NSString stringWithFormat:@"%@", fnameProperty];
        CFRelease(fnameProperty);
    }
    if (lnameProperty != nil) {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        CFRelease(lnameProperty);
    }
    if ([emailArray count] > 0) {
        email = [NSString stringWithFormat:@"%@", emailArray[0]];
    }
    if ([phoneArray count] > 0) {
        phone = [NSString stringWithFormat:@"%@", phoneArray[0]];
    }
    
    NSString *msg = @"I am inviting you to check out my photos on 2by2. Download the app, it's totally free! https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8";
    
    [[MainViewController currentController] dismissViewControllerAnimated:YES completion:^{
        if (email && phone) {
            UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:@"Send message by:"];
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
        [controller setMessageBody:@"I am inviting you to check out my photos on 2by2. <a href='https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8'>Download the app, it's totally free!</a>" isHTML:YES];
        [[MainViewController currentController] presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        controller.recipients = recipients;
        controller.body = bodyOfMessage;
        [[MainViewController currentController] presentViewController:controller animated:YES completion:nil];
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
