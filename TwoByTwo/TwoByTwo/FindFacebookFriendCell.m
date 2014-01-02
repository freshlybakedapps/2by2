//
//  FindFacebookFriendCell.m
//  TwoByTwo
//
//  Created by John Tubert on 11/30/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FindFacebookFriendCell.h"
#import "NSString+MD5.h"
#import "UIImageView+Network.h"
#import "UIImageView+CircleMask.h"

@implementation FindFacebookFriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 facebookID = 100006174907836;
 following = 1;
 name = "Gabriela Tubert";
 parseID = zqRi8FTL8j;
 */

- (void)setData:(NSDictionary *)data
{
    _data = data;
    
    //facebook photo
    //https://developers.facebook.com/docs/reference/api/using-pictures/#sizes
    NSString *url = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square",data[@"facebookID"]];
    NSURL *imageURL = [NSURL URLWithString:url];
    
    
    self.imageView.frame = CGRectMake(5, 15, 35, 35);   
    [self.imageView loadImageFromURL:imageURL placeholderImage:[UIImage imageNamed:@"icon-you"] cachingKey:[imageURL.absoluteString MD5Hash]];
    
    [self.imageView addMaskToBounds:CGRectMake(5, 15, 35, 35)];
    
    self.textLabel.text = data[@"name"];
    
    NSString* title;
    
    
    if(data[@"following"] == [NSNumber numberWithBool:YES]){
        title = @"Unfollow";
    }else{
        title = @"Follow";
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(follow:) forControlEvents:UIControlEventTouchDown];
    [button setTitle:title forState:UIControlStateNormal];
    button.frame = CGRectMake(0.0, 0.0, 90.0, 40.0);
    self.accessoryView = button;
    
    [self setNeedsDisplay];
    
}

- (void) follow:(UIButton*)b {
    b.enabled = NO;
    [PFCloud callFunctionInBackground:@"follow"
                       withParameters:@{@"userID":[PFUser currentUser].objectId,@"username":[PFUser currentUser].username,@"followingUserID":self.data[@"parseID"]}
                                block:^(NSNumber *result, NSError *error) {
                                    
                                    b.enabled = YES;
                                    
                                    if (!error) {
                                        NSLog(@"Follow: %@", result);
                                        if(result == 0){
                                            [b setTitle:@"Follow" forState:UIControlStateNormal];
                                        }else{
                                            [b setTitle:@"Unfollow" forState:UIControlStateNormal];
                                        }
                                        
                                    }
                                }];

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
