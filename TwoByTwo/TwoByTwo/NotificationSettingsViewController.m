//
//  NotificationSettingsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/27/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "NotificationSettingCell.h"

typedef NS_ENUM(NSUInteger, TableViewSection) {
    TableViewSectionEmail = 0,
    TableViewSectionPush,
    TableViewSectionDigest,
    TableViewSectionCount,
};

typedef NS_ENUM(NSUInteger, TableViewRow) {
    TableViewRowOverexpose = 0,
    TableViewRowLike,
    TableViewRowFollow,
    TableViewRowComment,
    TableViewRowCount,
};

typedef NS_ENUM(NSUInteger, TableViewDigestRow) {
    TableViewDigestRowWeekly = 0,
    TableViewDigestRowCount,
};


@interface NotificationSettingsViewController ()

@end


@implementation NotificationSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Notification Settings";
    
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        [self.tableView reloadData];
    }];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TableViewSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TableViewSectionEmail:
            return TableViewRowCount;

        case TableViewSectionPush:
            return TableViewRowCount;

        case TableViewSectionDigest:
        default:
            return TableViewDigestRowCount;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case TableViewSectionEmail:
            return @"Send me an email when someone:";
            
        case TableViewSectionPush:
            return @"Send me a push notification when someone:";
            
        case TableViewSectionDigest:
        default:
            return @"Send my once a email digest:";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationSettingCell" forIndexPath:indexPath];

    cell.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor colorWithWhite:0.98 alpha:1.0] : [UIColor colorWithWhite:0.95 alpha:1.0];
    
    switch (indexPath.section) {
        case TableViewSectionEmail:
            switch (indexPath.row) {
                case TableViewRowOverexpose:
                    cell.textLabel.text = @"Overexposes my photo";
                    cell.key = @"overexposeEmailAlert";
                    break;
                case TableViewRowLike:
                    cell.textLabel.text = @"Likes my photo";
                    cell.key = @"likesEmailAlert";
                    break;
                case TableViewRowFollow:
                    cell.textLabel.text = @"Follows me";
                    cell.key = @"followsEmailAlert";
                    break;
                case TableViewRowComment:
                default:
                    cell.textLabel.text = @"Comments";
                    cell.key = @"commentsEmailAlert";
                    break;
            }
            break;

        case TableViewSectionPush:
            switch (indexPath.row) {
                case TableViewRowOverexpose:
                    cell.textLabel.text = @"Overexposes my photo";
                    cell.key = @"overexposePushAlert";
                    break;
                case TableViewRowLike:
                    cell.textLabel.text = @"Likes my photo";
                    cell.key = @"likesPushAlert";
                    break;
                case TableViewRowFollow:
                    cell.textLabel.text = @"Follows me";
                    cell.key = @"followsPushAlert";
                    break;
                case TableViewRowComment:
                default:
                    cell.textLabel.text = @"Comments";
                    cell.key = @"commentsPushAlert";
                    break;
            }
            break;

        case TableViewSectionDigest:
        default:
            switch (indexPath.row) {
                case TableViewDigestRowWeekly:
                default:
                    cell.textLabel.text = @"Weekly digest";
                    cell.key = @"digestEmailAlert";
                    break;
            }
            break;
    }

    return cell;
}

@end
