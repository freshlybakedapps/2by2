//
//  FindTwitterFriendsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 4/7/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FindTwitterFriendsViewController.h"
#import "FindFacebookFriendCell.h"

@interface FindTwitterFriendsViewController ()
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) NSArray *friends;
@end

@implementation FindTwitterFriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Twitter Friends";
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:[UIColor appGrayColor],
                                                           NSFontAttributeName:[UIFont appMediumFontOfSize:14],
                                                           }];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FindFacebookFriendsCell" bundle:nil] forCellReuseIdentifier:@"FindFacebookFriendsCell"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSDictionary *normalAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont appFontOfSize:18], NSFontAttributeName,nil];
    self.navigationController.navigationBar.titleTextAttributes = normalAttributes;
    
    [self findTwitterFriends];
}

- (void)findTwitterFriends
{
    self.statusLabel.text = @"Checking Twitter contacts...";
    
    NSError *error;
    //https://dev.twitter.com/docs/api/1.1/get/friends/ids
    //friends/ids.json
    //friends/list.json
    //followers/ids.json
    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/friends/ids.json?screen_name=%@&count=5000", [PFTwitterUtils twitter].screenName];
    
    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if ( error == nil){
        NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        NSArray* ids = [result objectForKey:@"ids"];
        
        NSLog(@"%@",result);
        
        self.statusLabel.text = [NSString stringWithFormat:@"Found %lu Twitter contacts",(unsigned long)ids.count];
        
        [PFCloud callFunctionInBackground:@"getTwitterFriends"
                           withParameters:@{@"twitterFriends":ids}
                                    block:^(NSArray *result, NSError *error) {
                                        if (!error) {
                                            NSLog(@"Twitter friends: %@", result);
                                            
                                            
                                            self.statusLabel.text = [NSString stringWithFormat:@"Found %lu results", (unsigned long)result.count];
                                            
                                            if(result.count > 0){
                                                
                                                self.friends = result;
                                                [self.tableView reloadData];
                                            }
                                            
                                        }
                                    }];

        
        
    }else{
        NSLog(@"error %@",error.description);
    }

}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FindFacebookFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FindFacebookFriendsCell" forIndexPath:indexPath];
    
    cell.data = [self.friends objectAtIndex:indexPath.row];
    
    //if odd rows color them grey
    if((indexPath.row % 2) != 0){
        cell.backgroundColor = [[UIColor alloc] initWithRed:241/255.0f green:241/255.0f blue:241/255.0f alpha:1.0f];
    }
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
    
}


@end
