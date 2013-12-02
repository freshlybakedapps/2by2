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

@end

@implementation FindFacebookFriendsViewController

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
    self.navigationItem.title = @"Facebook";
    [self loadFriends];
}

- (void) loadFriends{
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
    return self.friends.count;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
*/

/*
 facebookID = 100006174907836;
 following = 1;
 name = "Gabriela Tubert";
 parseID = zqRi8FTL8j;
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
   FindFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindFacebookFriendCell" forIndexPath:indexPath];
    
    cell.data = [self.friends objectAtIndex:indexPath.row];
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}


@end
