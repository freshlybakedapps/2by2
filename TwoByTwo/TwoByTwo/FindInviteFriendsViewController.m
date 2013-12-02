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
        NSLog(@"No yet implemented");
    }
}




@end
