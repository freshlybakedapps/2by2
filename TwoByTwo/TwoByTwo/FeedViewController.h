//
//  FeedViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface FeedViewController : UICollectionViewController <ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic) FeedType type;
@property (nonatomic, strong) PFUser *user;

+ (instancetype)controller;

@end
