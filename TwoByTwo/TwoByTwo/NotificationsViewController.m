//
//  NotificationsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NotificationsViewController.h"
#import "FeedViewController.h"
#import "MainViewController.h"
#import "PDPViewController.h"
#import "NSDate+Addon.h"
#import "NotificationCell.h"


@interface NotificationsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *headerMessageLabel;
@property (nonatomic, strong) NSMutableArray *objects;
@end


@implementation NotificationsViewController

+ (instancetype)controller
{
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"NotificationsViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    self.headerTitleLabel.font = [UIFont appMediumFontOfSize:14];
    self.headerMessageLabel.font = [UIFont appMediumFontOfSize:13];

    NSString *keyStoreValue = [NSString stringWithFormat:@"messageWasSeen_notification"];
    if ([[NSUbiquitousKeyValueStore defaultStore] stringForKey:keyStoreValue]) {
        self.tableView.tableHeaderView = nil;
    }
    
    
    //Since viewer is seeing the notifications we should set them back to zero
    [[NSNotificationCenter defaultCenter] postNotificationName:NoficationDidUpdatePushNotificationCount object:self userInfo:@{NoficationUserInfoKeyCount:@0}];
    
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Content

- (IBAction)headerCloseButtonTapped:(id)sender
{
    NSString* keyStoreValue = [NSString stringWithFormat:@"messageWasSeen_notification"];
    [[NSUbiquitousKeyValueStore defaultStore] setString:@"YES" forKey:keyStoreValue];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    [self.tableView beginUpdates];
    self.tableView.tableHeaderView = nil;
    [self.tableView endUpdates];
}

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:PFNotificationClass];
    [query whereKey:PFNotificationIDKey equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:PFCreatedAtKey];
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = self.objects[indexPath.row];
    NSString *text = notification[@"content"];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(260, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont appFontOfSize:16]}
                                     context:nil];
    
    CGFloat cellHeight = 38 + rect.size.height + 10;
    return cellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell"];
    cell.notification = self.objects[indexPath.row];
    return cell;   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = self.objects[indexPath.row];
    NSString* photoID = notification[PFPhotoIDKey];
    NSString* byUserID = notification[@"byUserID"];
    
    if (![photoID isEqualToString:@"0"] && ![photoID isEqualToString:@""]) {
        PDPViewController *controller = [PDPViewController controller];
        controller.photoID = photoID;
        [self.navigationController pushViewController:controller animated:YES];        
    }
    else {
        FeedViewController *controller = [FeedViewController controller];
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