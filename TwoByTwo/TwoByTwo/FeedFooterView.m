//
//  FeedFooterView.m
//  TwoByTwo
//
//  Created by John Tubert on 1/27/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FeedFooterView.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface FeedFooterView ()
@property (nonatomic, weak) IBOutlet UILabel *textLabel;

@property (nonatomic, weak) IBOutlet UIButton *inviteFacebookButton;
@end


@implementation FeedFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.textLabel.font = [UIFont appMediumFontOfSize:14];
}

- (IBAction)inviteEmailButtonTapped:(id)sender
{
    
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self.controller;
    [self.controller presentViewController:picker animated:YES completion:nil];

}

- (IBAction)inviteFacebookButtonTapped:(UIButton *)sender
{
    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys: nil];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Hey, inviting you to check out my pics on 2by2, join and we can make double exposures together. Download the app here: https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8"
                                                    title:@"2by2!"
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if (error) {
                                                          // Case A: Error launching the dialog or sending request.
                                                          NSLog(@"Error sending request.");
                                                      } else {
                                                          if (result == FBWebDialogResultDialogNotCompleted) {
                                                              // Case B: User clicked the "x" icon
                                                              NSLog(@"User canceled request.");
                                                          } else {
                                                              NSLog(@"Request Sent. %@",resultURL);
                                                          }
                                                      }}
                                              friendCache:nil];
}


- (void)setType:(FeedType)type
{
    _type = type;
    
    
    switch (type) {
            
        case FeedTypeYou:
            if(!self.showingDouble){
                self.textLabel.text = @"Not much going on here yet. Take a photo by tapping below.";
            }else{
                self.textLabel.text = @"Not much going on here yet. Go to any single exposed photo and tap on it to create a double exposure";
            }
            break;
        case FeedTypeFollowing:
            self.textLabel.text = @"Nothing to show here yet, swing by later.";
            break;
        case FeedTypeFriend:
            if(!self.showingDouble){
                self.textLabel.text = @"This person doesn't have any single exposed photos.";
            }else{
                self.textLabel.text = @"This person doesn't have any double exposed photos.";
            }
            break;
        case FeedTypeSingle:
            self.textLabel.text = @"Single exposed photos ran out, swing by later.";
            break;
        case FeedTypeGlobal:
            self.textLabel.text = @"Nothing to show here yet, swing by later.";
            break;
        default:
            self.textLabel.text = @"";
            break;
    }
}




@end
