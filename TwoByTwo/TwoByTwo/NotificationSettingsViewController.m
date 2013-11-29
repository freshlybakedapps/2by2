//
//  NotificationSettingsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 11/27/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NotificationSettingsViewController.h"
#import "GridHeaderView.h"

typedef NS_ENUM(NSUInteger, SwitchNum) {
    SwitchNumEmail0 = 1000,
    SwitchNumEmail1 = 1001,
    SwitchNumEmail2 = 1002,
    SwitchNumPush0 = 1100,
    SwitchNumPush1 = 1101,
    SwitchNumPush2 = 1102,
    SwitchNumDigest = 1200,
};


@interface NotificationSettingsViewController ()

@end

@implementation NotificationSettingsViewController

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
    self.navigationItem.title = @"Notification Settings";    
    //self.clearsSelectionOnViewWillAppear = NO;
    
    
    
    //get user info again
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
        self.emailSection = [NSMutableArray new];
        self.pushSection = [NSMutableArray new];
        self.digestSection = [NSMutableArray new];
        
        [self.emailSection addObject:@"Overexposes my photo"];
        [self.emailSection addObject:@"Likes my photo"];
        [self.emailSection addObject:@"Follows me"];
        
        [self.pushSection addObject:@"Overexposes my photo"];
        [self.pushSection addObject:@"Likes my photo"];
        [self.pushSection addObject:@"Follows me"];
        
        [self.digestSection addObject:@"Weekly digest"];
        
        
        [self addFooter];
        
        [self.tableView reloadData];

    }];
    
}


- (void) addFooter{
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 320, 100)];
    
    UITextView *textField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    textField.editable = NO;
    
    textField.text = @"Modify any settings as desired  and tap on \"Save changes\"";
    [footerView addSubview:textField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Save changes" forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 50.0, 320.0, 40.0);
    [footerView addSubview:button];
    
    //[footerView setBackgroundColor:[UIColor redColor]];
    self.tableView.tableFooterView = footerView;
    [self.tableView setSeparatorStyle:(UITableViewCellSeparatorStyleNone)];
    //[self.tableView setContentInset:(UIEdgeInsetsMake(0, 0, -500, 0))];
}

- (BOOL) switchStateOn:(NSInteger)num{
    UISwitch *s = (UISwitch*)[self.view viewWithTag:num];
    
    if(s.isOn){
        return YES;
    }else{
        return NO;
    }
}

- (void) save{
    BOOL email0 = [self switchStateOn:SwitchNumEmail0];
    BOOL email1 = [self switchStateOn:SwitchNumEmail1];
    BOOL email2 = [self switchStateOn:SwitchNumEmail2];
    BOOL push0 = [self switchStateOn:SwitchNumPush0];
    BOOL push1 = [self switchStateOn:SwitchNumPush1];
    BOOL push2 = [self switchStateOn:SwitchNumPush2];
    BOOL digest = [self switchStateOn:SwitchNumDigest];
    
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:email0] forKey:@"overexposeEmailAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:email1] forKey:@"likesEmailAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:email2] forKey:@"followsEmailAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:push0] forKey:@"overexposePushAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:push1] forKey:@"likesPushAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:push2] forKey:@"followsPushAlert"];
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:digest] forKey:@"digestEmailAlert"];
    
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!succeeded){
            NSLog(@"error: %@",error.description);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }else{
            NSLog(@"succeeded saving preferences");
            [[[UIAlertView alloc] initWithTitle:@"Save changes" message:@"All changes have been saved." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return self.emailSection.count;
            break;
        case 1:
            return self.pushSection.count;
            break;
        case 2:
            return self.digestSection.count;
            break;
        default:
            return 0;
            break;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Send me an email when someone:";
            break;
        case 1:
            sectionName = @"Send me a push notification when someone:";
            break;
        case 2:
            sectionName = @"Send my once a email digest:";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

/*
- (void)updateSwitchAtIndexPath:(UISwitch *)aswitch{
    if(aswitch.isOn){
        NSLog(@"%ld is on", (long)aswitch.tag);
    }else{
        NSLog(@"%ld is off", (long)aswitch.tag);
    }
}
*/


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWithSwitch" forIndexPath:indexPath];
    UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
    cell.accessoryView = switchview;
    
    //Generating a unique tag based on the section and row number
    NSInteger section = indexPath.section*100;
    switchview.tag = 1000+section+indexPath.row;
    
    //Switch it on or off depending on what's coming back from server
    switch (switchview.tag) {
        case SwitchNumEmail0:
            if([PFUser currentUser][@"overexposeEmailAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumEmail1:
            if([PFUser currentUser][@"likesEmailAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumEmail2:
            if([PFUser currentUser][@"followsEmailAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumPush0:
            if([PFUser currentUser][@"overexposePushAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumPush1:
            if([PFUser currentUser][@"likesPushAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumPush2:
            if([PFUser currentUser][@"followsPushAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
        case SwitchNumDigest:
            if([PFUser currentUser][@"digestEmailAlert"] == [NSNumber numberWithBool:1]){
                [switchview setOn:YES];
            }
            break;
            
        default:
            break;
    }
    
    //[switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventTouchUpInside];
    
    
    switch (indexPath.section)
    {
        case 0:
            cell.textLabel.text = [self.emailSection objectAtIndex:indexPath.row];
            break;
        case 1:
            cell.textLabel.text = [self.pushSection objectAtIndex:indexPath.row];
            break;
        case 2:
            cell.textLabel.text = [self.digestSection objectAtIndex:indexPath.row];
            break;
        default:
            cell.textLabel.text = @"";
            break;
    }    
    
    return cell;

}


/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
*/

@end
