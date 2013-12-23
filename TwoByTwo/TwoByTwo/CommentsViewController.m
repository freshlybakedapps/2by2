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
    
    self.navigationItem.title = @"Comments for this photo";
    
    self.navigationItem.hidesBackButton = NO;
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                             style:UIBarButtonItemStyleBordered
                                                                            target:self
                                                                            action:@selector(close:)];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           65.0f,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - 105.0f)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    //self.tableView.rowHeight = 79.f;
    
    [self.view addSubview:self.tableView];
    
    
    
    
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - 40.0f,
                                                                     self.view.bounds.size.width,
                                                                     40.0f)];
    
    toolBar.backgroundColor = [UIColor darkGrayColor];
    
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
    
    @try {
        UIImage *image = [self imageWithColor:[UIColor colorWithRed:0.0/255.0 green:204.0/255.0 blue:153.0/255.0 alpha:1.0]];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        NSLog(@"imageWithColor exception %@",exception.description);
    }
    
    
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setTitle:@"Post" forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(toolBar.bounds.size.width - 68.0f,
                                  6.0f,
                                  58.0f,
                                  29.0f);
    
    
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchDown];
    [toolBar addSubview:sendButton];
    
    __weak typeof(self) weakSelf = self;
    
    
    @try {
        self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
        
        
        
        //https://github.com/danielamitay/DAKeyboardControl
        
        
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
            tableViewFrame.size.height = toolBarFrame.origin.y - 65;
            weakSelf.tableView.frame = tableViewFrame;
            
            if(weakSelf.objects.count > 0){
                NSIndexPath* ipath = [NSIndexPath indexPathForRow: weakSelf.objects.count-1 inSection: 0];
                [weakSelf.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
            }            
            
        }];
        

    }
    @catch (NSException *exception) {
        NSLog(@"addKeyboardPanningWithActionHandler exception: %@",exception.description);
    }
    
    [self performQuery];

}


- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"commentID" equalTo:self.commentID];
    [query orderByAscending:@"createdAt"];
    //[query setCachePolicy:kPFCachePolicyNetworkElseCache];
    
    __weak typeof(self) weakSelf = self;
    
    self.objects = [NSMutableArray new];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if(objects.count > 0){
                [weakSelf.objects addObjectsFromArray:objects];
                [weakSelf.tableView reloadData];
                
                @try {
                    NSIndexPath* ipath = [NSIndexPath indexPathForRow: weakSelf.objects.count-1 inSection: 0];
                    [weakSelf.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
                }
                @catch (NSException *exception) {
                    NSLog(@"performQuery/exception: %@",exception.description);
                }
            }
        }
    }];
}



- (void)send:(id)sender{
    if([self.textField.text isEqualToString:@""]){
        return;
    }
    
    
    UIButton *sendButton = (UIButton*)sender;
    sendButton.enabled = NO;
    
    NSString *t = self.textField.text;
    NSString *u = [PFUser currentUser].username;
    NSString *c = self.commentID;
    NSString *fb = [PFUser currentUser][@"facebookId"];
    NSString *userID = [PFUser currentUser].objectId;
    
    NSLog(@"%@ / %@ / %@ / %@ / %@",t,u,c,fb,userID);
    
    

    
    
    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    
    @try {
        comment[@"text"] = t;
        comment[@"username"] = u;
        comment[@"commentID"] = c;
        comment[@"facebookId"] = fb;
        comment[@"userID"] = userID;
    }
    @catch (NSException *exception) {
        NSLog(@"send/exception: %@",exception.description);
    }
    
    
    
    __weak typeof(self) weakSelf = self;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        weakSelf.textField.text = @"";
        @try {
            if(!error){
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
                
                if(weakSelf.objects.count > 0){
                    NSIndexPath* ipath = [NSIndexPath indexPathForRow: weakSelf.objects.count-1 inSection: 0];
                    [weakSelf.tableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionTop animated: YES];
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"insertRowsAtIndexPaths/exception: %@",exception.description);
        }
        
        sendButton.enabled = YES;
    }];
}

- (void) cleanUp{
    self.commentID = nil;
    self.objects = nil;
    self.textField = nil;
    self.tableView = nil;
    [self.view removeKeyboardControl];
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
    //NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"second", @"minute", @"hour", @"day", @"week", @"month", @"year", @"decade", nil];
    
    NSMutableArray *periods = [NSMutableArray arrayWithObjects:@"s", @"m", @"h", @"d", @"w", @"month", @"year", @"decade", nil];
    
    NSArray *lengths = [NSArray arrayWithObjects:@60, @60, @24, @7, @4.35, @12, @10, nil];
    int j = 0;
    for(j=0; difference >= [[lengths objectAtIndex:j] doubleValue]; j++)
    {
        difference /= [[lengths objectAtIndex:j] doubleValue];
    }
    difference = roundl(difference);
    if(difference != 1)
    {
        //[periods insertObject:[[periods objectAtIndex:j] stringByAppendingString:@"s"] atIndex:j];
    }
    
    if(difference < 0){
        difference = 0;
    }
    
    return [NSString stringWithFormat:@"%li%@%@", (long)difference, [periods objectAtIndex:j], @""];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *comment = [self.objects objectAtIndex:indexPath.row];
    
    //only allow to edit my own comments
    if([comment[@"username"] isEqualToString:[PFUser currentUser].username]){
        return YES;
    }else{
        return NO;
    }   
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *comment = [self.objects objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            @try {
                if(!error){
                    [weakSelf.tableView beginUpdates];
                    [weakSelf.objects removeObject:comment];
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

//TODO: move this to a custom cell class
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    PFObject *comment = [self.objects objectAtIndex:indexPath.row];
    
    //NSLog(@"comment:  %@",comment);
    
    cell.textLabel.text = comment[@"username"];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
    cell.textLabel.textColor = [UIColor colorWithRed:0.0/255.0
                                               green:204.0/255.0
                                                blue:153.0/255.0
                                               alpha:1.0];
    
    
    cell.detailTextLabel.text = comment[@"text" ];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal",comment[@"facebookId"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    
    
    [cell.imageView loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    [cell.imageView addMaskToBounds:CGRectMake(0, 0, 45, 45)];
    //cell.imageView.clipsToBounds = YES;
    @try {
        cell.imageView.image = [self resetImage:cell.imageView.image];
    }
    @catch (NSException *exception) {
        NSLog(@"resetImage/exception: %@",exception.description);
    }
    
    
    UILabel* timeStamplabel = [ [UILabel alloc ] initWithFrame:CGRectMake(0.0, 00.0, 80.0, 43.0) ];
    timeStamplabel.textAlignment = UIControlContentHorizontalAlignmentRight;
    timeStamplabel.textColor = [UIColor grayColor];
    timeStamplabel.font = [UIFont boldSystemFontOfSize:11];
    
    timeStamplabel.text = [self timeAgoFromUnixTime:[comment.createdAt timeIntervalSince1970]];
    cell.accessoryView = timeStamplabel;
    
    
    
    return cell;
}

- (UIImage *)resetImage:(UIImage*)originalImage {
    
    CGSize newSize = CGSizeMake(50, 50);
    CGRect imageRect = CGRectMake(0,0, newSize.width,newSize.height);
    
    UIGraphicsBeginImageContext(newSize);
    [originalImage drawInRect:imageRect];
    UIImage *theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return theImage;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *comment = [self.objects objectAtIndex:indexPath.row];
    if(comment){
        NSString *cellText = comment[@"text"];
        UIFont *cellFont = [UIFont systemFontOfSize:13];
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

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
