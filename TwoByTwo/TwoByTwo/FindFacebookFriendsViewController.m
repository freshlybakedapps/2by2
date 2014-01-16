//
//  FindFacebookFriendsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/30/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FindFacebookFriendsViewController.h"
#import "FindFacebookFriendCell.h"


@interface FindFacebookFriendsViewController ()
@property (strong,nonatomic) NSArray* friends;
@end


@implementation FindFacebookFriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Facebook";
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont appFontOfSize:18], NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = normalAttributes;
    
    [self loadFriends];
}

- (void)loadFriends
{
    [PFCloud callFunctionInBackground:@"getFacebookFriends"
                       withParameters:@{@"user":[PFUser currentUser].objectId}
                                block:^(NSArray *result, NSError *error) {
                                    if (!error) {
                                        NSLog(@"Facebook friends: %@", result);
                                        self.friends = result;
                                        [self.tableView reloadData];
                                    }
                                }];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindFacebookFriendCell" forIndexPath:indexPath];
    cell.data = self.friends[indexPath.row];
    cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor colorWithWhite:0.98 alpha:1.0] : [UIColor colorWithWhite:0.95 alpha:1.0];
    return cell;
}


@end
