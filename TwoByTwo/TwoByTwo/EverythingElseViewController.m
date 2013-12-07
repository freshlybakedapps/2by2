//
//  EverythingElseViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/27/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "EverythingElseViewController.h"
#import "NotificationSettingsViewController.h"
#import "AboutViewController.h"
#import "FindInviteFriendsViewController.h"
#import "AppDelegate.h"


@interface EverythingElseViewController ()

@end

@implementation EverythingElseViewController

+ (instancetype)controller
{
    EverythingElseViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"EverythingElseViewController"];
    return controller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Everything else";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
    
    self.sections = [NSMutableArray new];
    [self.sections addObject:@"About 2by2"];
    [self.sections addObject:@"Notification settings"];
    [self.sections addObject:@"Find & Invite friends"];
    [self.sections addObject:@"logout"];
    
}

-(void)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"controller dismissed"); }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }

    
    NSString* str = [self.sections objectAtIndex:indexPath.row];
    
    if([str isEqualToString:@"logout"]){
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [logoutButton addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchDown];
        [logoutButton setTitle:@"Log out (But comeback soon)" forState:UIControlStateNormal];
        [logoutButton setTintColor:[UIColor whiteColor]];
        logoutButton.frame = CGRectMake(10.0, 0.0, 300.0, 40.0);
        cell.backgroundColor = [[UIColor alloc] initWithRed:255/255.0f green:51/255.0f blue:102/255.0f alpha:1.0f];

        [cell.contentView addSubview:logoutButton];
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.text = str;
    }
    
    
    return cell;
}

- (void) logOut{
    [UIAlertView showAlertViewWithTitle:@"Confirm" message:@"Are you sure you want to logout?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"OK"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            [PFUser logOut];
            [[AppDelegate delegate] showLoginViewController];
        }
    }];
   
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0){
        AboutViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }else if(indexPath.row == 1){
        NotificationSettingsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationSettingsViewController"];
        [self.navigationController pushViewController:controller animated:YES];
        
    }else if(indexPath.row == 2){
        FindInviteFriendsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FindInviteFriendsViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
