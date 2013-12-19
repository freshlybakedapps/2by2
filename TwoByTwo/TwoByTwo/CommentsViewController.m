//
//  CommentsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/18/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CommentsViewController.h"
#import "DAKeyboardControl.h"
#import "NSString+MD5.h"
#import "UIImageView+Network.h"
#import "UIImageView+CircleMask.h"

@interface CommentsViewController ()

@end

@implementation CommentsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;self.navigationItem.title = @"Notification";
    
    self.navigationItem.title = @"Comments";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           80.0f,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - 120.0f)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
    
    
    
    
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - 40.0f,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolBar];
    
    
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f,
                                                                           6.0f,
                                                                           toolBar.bounds.size.width - 20.0f - 68.0f,
                                                                           30.0f)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [toolBar addSubview:self.textField];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Send" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchDown];

    
    
    [toolBar addSubview:sendButton];
    
    
    self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
    
    __weak typeof(self) weakSelf = self;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        CGRect toolBarFrame = toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        toolBar.frame = toolBarFrame;
        
        CGRect tableViewFrame = weakSelf.tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        weakSelf.tableView.frame = tableViewFrame;
    }];
    
    [self performQuery];

}

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"commentID" equalTo:self.commentID];
    [query orderByDescending:@"createdAt"];
    
    __weak typeof(self) weakSelf = self;
    
    self.objects = [NSMutableArray new];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error) {
            NSLog(@"objects!!! %@",objects);
            if(objects.count > 0){
                [weakSelf.objects addObjectsFromArray:objects];
                [weakSelf.tableView reloadData];
            }
            
        }
    }];
    
}



- (void)send:(id)sender{
    UIButton *sendButton = (UIButton*)sender;
    sendButton.enabled = NO;
    
    NSLog(@"%@",sendButton);
    
    NSString *t = self.textField.text;
    NSString *u = [PFUser currentUser].username;
    NSString *c = self.commentID;
    NSString *fb = [PFUser currentUser][@"facebookId"];
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"text"] = t;
    comment[@"username"] = u;
    comment[@"commentID"] = c;
    comment[@"facebookId"] = fb;
    
    __weak typeof(self) weakSelf = self;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        weakSelf.textField.text = @"";
        @try {
            [weakSelf.tableView beginUpdates];
             
            int resultsSize = [weakSelf.objects count];
            [weakSelf.objects addObject:comment];
            NSMutableArray *arrayWithIndexPaths = [NSMutableArray array];
            for (int i = resultsSize; i < resultsSize + 1; i++)
            {
                [arrayWithIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
            
            [weakSelf.tableView insertRowsAtIndexPaths:arrayWithIndexPaths withRowAnimation:UITableViewRowAnimationRight];
            [weakSelf.tableView endUpdates];
        }
        @catch (NSException *exception) {
            NSLog(@"%@",exception.description);
        }
        
        
        //NSLog(@"%@ / %@ / %@",t,u,fb);
        sendButton.enabled = YES;
    }];
}

-(void)close:(id)sender
{
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"%lu",(unsigned long)self.objects.count);
    
    
    return self.objects.count;
}

- (NSString *)timeAgoFromUnixTime:(double)seconds
{
    double difference = [[NSDate date] timeIntervalSince1970] - seconds;
    NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"second", @"minute", @"hour", @"day", @"week", @"month", @"year", @"decade", nil];
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
    return [NSString stringWithFormat:@"%li %@%@", (long)difference, [periods objectAtIndex:j], @" ago"];
}

//TODO: move this to a custom cell class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"comment");
    
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    
    PFObject *comment = [self.objects objectAtIndex:indexPath.row];
    
    NSLog(@"comment:  %@",comment);
    
    cell.textLabel.text = comment[@"text"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
    cell.detailTextLabel.text = comment[@"username" ];
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",comment[@"facebookId"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    //cell.imageView.frame = CGRectMake(20, 0, 100, 100);
    [cell.imageView loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    //[cell.imageView addMaskToBounds:CGRectMake(0, 0, 75, 75)];
    
    UILabel* label = [ [UILabel alloc ] initWithFrame:CGRectMake(0.0, 00.0, 80.0, 43.0) ];
    label.textAlignment = UIControlContentHorizontalAlignmentRight;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont boldSystemFontOfSize:11];
    
    label.text = [self timeAgoFromUnixTime:[comment.createdAt timeIntervalSince1970]];
    cell.accessoryView = label;
    
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
