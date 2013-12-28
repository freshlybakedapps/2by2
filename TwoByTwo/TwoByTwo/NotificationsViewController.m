//
//  NotificationsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/22/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "NotificationsViewController.h"
#import "PDPViewController.h"
#import "FriendProfileViewController.h"
#import "MainViewController.h"


@interface NotificationsViewController ()

@end

@implementation NotificationsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                   120.0f,
                                                                   self.view.bounds.size.width,
                                                                   self.view.bounds.size.height - 105.0f)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    //self.tableView.rowHeight = 79.f;
    
    
    [self.view addSubview:self.tableView];
    
    [MainViewController updateNotification:0];
    
    [PFUser currentUser][@"notificationWasAccessed"] = [self toLocalTime:[NSDate new]];
    [[PFUser currentUser] saveEventually];
    
    [self performQuery];
}

-(NSDate *) toLocalTime:(NSDate*)d
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: d];
    return [NSDate dateWithTimeInterval: seconds sinceDate: d];
}




- (void) viewDidAppear:(BOOL)animated{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}



- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
    [query whereKey:@"notificationID" equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:@"createdAt"];
    //[query setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    __weak typeof(self) weakSelf = self;
    
    self.objects = [NSMutableArray new];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(objects.count > 0){
                [weakSelf.objects addObjectsFromArray:objects];
                [weakSelf.tableView reloadData];
                
                @try {
                    //NSIndexPath* ipath = [NSIndexPath indexPathForRow: weakSelf.objects.count-1 inSection: 0];
                    //[weakSelf.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
                }
                @catch (NSException *exception) {
                    NSLog(@"performQuery/exception: %@",exception.description);
                }
            }
        }
    }];
}




- (void) cleanUp{
    self.objects = nil;
    self.tableView = nil;
}

-(void)close:(id)sender
{
    [self cleanUp];
    [self dismissViewControllerAnimated:YES completion:^{ NSLog(@"controller dismissed"); }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (NSString *)timeAgoFromUnixTime:(double)seconds
{
    double difference = [[NSDate date] timeIntervalSince1970] - seconds;
    NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"second", @"minute", @"hour", @"day", @"week", @"month", @"year", @"decade", nil];
    
    //NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"s", @"m", @"h", @"d", @"w", @"month", @"year", @"decade", nil];
    
    NSArray *lengths = [NSArray arrayWithObjects:@60, @60, @24, @7, @4.35, @12, @10, nil];
    int j = 0;
    for(j=0; difference >= [[lengths objectAtIndex:j] doubleValue]; j++)
    {
        difference /= [[lengths objectAtIndex:j] doubleValue];
    }
    difference = roundl(difference);
    if(difference != 1)
    {
        [periods insertObject:[[periods objectAtIndex:j] stringByAppendingString:@"s"] atIndex:j];
    }
    
    if(difference < 0){
        difference = 0;
    }
    
    return [NSString stringWithFormat:@"%li %@%@", (long)difference, [periods objectAtIndex:j], @" ago"];
}


//TODO: move this to a custom cell class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PFObject *notification = [self.objects objectAtIndex:indexPath.row];
    
    //NSLog(@"notification:  %@",notification);
    
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
    
    
    
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [self timeAgoFromUnixTime:[notification.createdAt timeIntervalSince1970]];
    
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0/255.0
                                                     green:204.0/255.0
                                                      blue:153.0/255.0
                                                     alpha:1.0];
    cell.textLabel.text = [self getLabel:notification];
    
    return cell;
}

- (NSString*) getLabel:(PFObject*)notification{
    NSString* s;
    
    NSString* notificationType = notification[@"notificationType"];
    
    if([notificationType isEqualToString:@"comment"]){
        s = [NSString stringWithFormat:@"Your photo was commented by %@",notification[@"byUsername"]];
    }else if([notificationType isEqualToString:@"overexposed"]){
        s = [NSString stringWithFormat:@"Your photo was overexposed by %@",notification[@"byUsername"]];
    }else if([notificationType isEqualToString:@"follow"]){
        s = [NSString stringWithFormat:@"You have a new follower"];
    }else if([notificationType isEqualToString:@"like"]){
        s = [NSString stringWithFormat:@"Your photo was liked by %@",notification[@"byUsername"]];
    }else if([notificationType isEqualToString:@"newUser"]){
        s = [NSString stringWithFormat:@"Your facebook friend %@ just joined 2by2",notification[@"byUsername"]];
    }else if([notificationType isEqualToString:@"flag"]){
        NSString *flagType = notification[@"content"];
        flagType = [flagType stringByReplacingOccurrencesOfString:@"FlagType" withString:@""];
        
        s = [NSString stringWithFormat:@"Your photo was flagged as %@",flagType];
    }
    
    return s;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = [self.objects objectAtIndex:indexPath.row];
    if(notification){
        NSString* s = [self getLabel:notification];
        NSString *cellText = s;
        UIFont *cellFont = [UIFont systemFontOfSize:15];
        CGSize constraintSize = CGSizeMake(300.0f, MAXFLOAT);
        //CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        CGRect labelSize = [cellText boundingRectWithSize:constraintSize
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:cellFont}
                                                  context:nil];
        
        return labelSize.size.height + 45;
        
    }else{
        return 60;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *notification = [self.objects objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [notification deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            @try {
                if(!error){
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.objects removeObject:notification];
                    [weakSelf.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject: indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.tableView endUpdates];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"deleteRowsAtIndexPaths/exception: %@ / %@",indexPath, exception.description);
            }
        }];
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = [self.objects objectAtIndex:indexPath.row];
    NSString* photoID = notification[@"photoID"];
    NSString* byUserID = notification[@"byUserID"];
    //NSString* friendName = notification[@"byUsername"];
    
    NSLog(@"photoID: %@",photoID);
    
    if(![photoID isEqualToString:@"0"] && ![photoID isEqualToString:@""]){
        UINavigationController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PDPViewController"];
        PDPViewController * pdp = (PDPViewController*)controller.topViewController;
        pdp.photoID = photoID;
        [self presentViewController:controller animated:YES completion:nil];
    }else{
        UINavigationController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendProfileViewController"];
        
        FriendProfileViewController * fvc = (FriendProfileViewController*)controller.topViewController;
        
        fvc.friend = [PFUser objectWithoutDataWithObjectId:byUserID];
        fvc.friendName = @"Friend";
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    
    

}


@end