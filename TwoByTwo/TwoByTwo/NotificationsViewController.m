//
//  NotificationsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NotificationsViewController.h"
#import "GridViewController.h"
#import "MainViewController.h"
#import "NSDate+Addon.h"


@interface NotificationsViewController ()
@property (nonatomic, strong) NSMutableArray *objects;
@end


@implementation NotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Since viewer is seeing the notifications we should set them back to zero
    [[AppDelegate delegate].mainNavigationBar updateNotificationCount:0];
    
    [PFUser currentUser][@"notificationWasAccessed"] = [NSDate date];
    [[PFUser currentUser] saveEventually];
    
    [self performQuery];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    /*
     Source:
     http://stackoverflow.com/questions/19038949/content-falls-beneath-navigation-bar-when-embedded-in-custom-container-view-cont
     */
    
    if ([parent isKindOfClass:[MainViewController class]] && self.navigationController.topViewController == parent) {
        CGFloat top = parent.topLayoutGuide.length;
        CGFloat bottom = parent.bottomLayoutGuide.length;
        if (self.tableView.contentInset.top != top) {
            UIEdgeInsets newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
            self.tableView.contentInset = newInsets;
            self.tableView.scrollIndicatorInsets = newInsets;
        }
    }
    else {
        [super didMoveToParentViewController:parent];
    }
}

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"notificationID" equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:@"createdAt"];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.objects = [objects mutableCopy];
            [weakSelf.tableView reloadData];
        }
    }];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];

    PFObject *notification = self.objects[indexPath.row];
    
    //NOTIFICATION TYPES
    // - comment
    // - overexposed
    // - follow
    // - like
    // - newUser
    // - flag
    
    //NOTIFICATON PROPERTIES
    // - notificationID (same as user ID)
    // - photoID
    // - notificationType
    // - byUserID
    // - byUsername
    // - content
    // - locationString


    NSString* notificationType = notification[@"notificationType"];
    if ([notificationType isEqualToString:@"comment"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Your photo was commented by %@", notification[@"byUsername"]];
    }
    else if([notificationType isEqualToString:@"overexposed"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Your photo was overexposed by %@", notification[@"byUsername"]];
    }
    else if([notificationType isEqualToString:@"follow"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"You have a new follower"];
    }
    else if([notificationType isEqualToString:@"like"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Your photo was liked by %@", notification[@"byUsername"]];
    }
    else if([notificationType isEqualToString:@"newUser"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Your facebook friend %@ just joined 2by2", notification[@"byUsername"]];
    }
    else if([notificationType isEqualToString:@"flag"]) {
        NSString *flagType = notification[@"content"];
        flagType = [flagType stringByReplacingOccurrencesOfString:@"FlagType" withString:@""];
        cell.textLabel.text = [NSString stringWithFormat:@"Your photo was flagged as %@", flagType];
    }
    
    cell.detailTextLabel.text = [notification.createdAt timeAgoString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = self.objects[indexPath.row];
    NSString* photoID = notification[@"photoID"];
    NSString* byUserID = notification[@"byUserID"];
    
    if (![photoID isEqualToString:@"0"] && ![photoID isEqualToString:@""]) {
        GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
        controller.type = FeedTypePDP;
        controller.photoID = photoID;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
        controller.type = FeedTypeFriend;
        controller.user = [PFUser objectWithoutDataWithObjectId:byUserID];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) weakSelf = self;
        PFObject *notification = self.objects[indexPath.row];
        [notification deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [weakSelf.tableView beginUpdates];
                [weakSelf.objects removeObject:notification];
                [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf.tableView endUpdates];
            }
        }];
    }
}


@end