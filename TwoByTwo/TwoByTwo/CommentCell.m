//
//  CommentCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 12/31/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CommentCell.h"
#import "UIImageView+AFNetworking.h"
#import "NSDate+Addon.h"
#import "FeedViewController.h"
#import "MainViewController.h"
#import <STTweetLabel.h>




@interface CommentCell ()
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) STTweetLabel *commentLabel;
@end


@implementation CommentCell

- (void)setComment:(PFObject *)comment
{
    __weak typeof(self) weakSelf = self;
    
    _comment = comment;

    NSURL *URL = [NSURL URLWithFacebookUserID:comment.facebookID];
    
    if(comment.twitterProfileImageURL && ![comment.twitterProfileImageURL isEqualToString:@""]){
        URL = [NSURL URLWithString:comment.twitterProfileImageURL];
    }
    
    [self.avatarImageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) * 0.5;
    self.nameLabel.text = comment[@"username"];
    self.dateLabel.text = [comment.createdAt timeAgoString];
    self.nameLabel.font = [UIFont appFontOfSize:14];
    self.dateLabel.font = [UIFont appFontOfSize:14];
    self.nameLabel.textColor = [UIColor appGreenColor];
    
    if(self.commentLabel && self.commentLabel.superview){
        [self.commentLabel removeFromSuperview];
    }

    
    self.commentLabel = [[STTweetLabel alloc] initWithFrame:CGRectMake(50.0, 37.0, 260.0, 300.0)];
    
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.textAlignment = NSTextAlignmentLeft;
    self.commentLabel.font = [UIFont appFontOfSize:14];
    [self.commentLabel setText:comment[@"text"]];
    CGSize size = [self.commentLabel suggestedFrameSizeToFitEntireStringConstraintedToWidth:self.commentLabel.frame.size.width];
    CGRect frame = self.commentLabel.frame;
    frame.size.width = 260.0;
    frame.size.height = size.height;
    [self.commentLabel setFrame:frame];
    
    [self addSubview:self.commentLabel];
    
    NSDictionary* hashAttr = @{NSForegroundColorAttributeName: [UIColor appGreenColor]};
    NSDictionary* generalAttr = @{NSForegroundColorAttributeName: [UIColor appGrayColor],NSFontAttributeName: [UIFont appFontOfSize:12]};
    
    
    [self.commentLabel setAttributes:hashAttr hotWord:0];
    [self.commentLabel setAttributes:hashAttr hotWord:1];
    [self.commentLabel setAttributes:hashAttr hotWord:2];
    [self.commentLabel setAttributes:generalAttr];
    
    [self.commentLabel setDetectionBlock:^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
        if(hotWord == 0){
            [weakSelf selectedMention:string];
        }else if(hotWord == 1){
            [weakSelf selectedHashtag:string];
        }else if(hotWord == 2){
            [weakSelf selectedLink:string];
        }
    }];
}

- (void)selectedMention:(NSString *)string {
     __weak typeof(self) weakSelf = self;
    
    PFQuery *query = [PFUser query];
    
    string = [string stringByReplacingOccurrencesOfString:@"@" withString:@""];
    [query whereKey:@"username" equalTo:string];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            if(objects.count > 0){
                PFUser* user = [objects objectAtIndex:0];
                
                @try {
                    FeedViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedViewController"];
                    controller.type = FeedTypeFriend;
                    controller.user = user;
                    [weakSelf.nav pushViewController:controller animated:YES];
                }
                @catch (NSException *exception) {
                    NSLog(@"error: %@",exception);
                }
                
                
            }else{
                NSString* msg = [NSString stringWithFormat:@"Username %@, doesn't exsist.",string];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
            
        }
        
        
        
    }];

    
    
   
    
}


- (void)selectedHashtag:(NSString *)string {
    NSLog(@"selectedHashtag");
    FeedViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedViewController"];
    controller.type = FeedTypeHashtag;
    controller.hashtag = string;
    [self.nav pushViewController:controller animated:YES];
}

- (void)selectedLink:(NSString *)string {
    NSURL *url = [NSURL URLWithString:string];
    
    if (![[UIApplication sharedApplication] openURL:url])
        NSLog(@"%@%@",@"Failed to open url:",[url description]);
}



+ (CGFloat)heightForComment:(PFObject *)comment
{
    NSString *text = comment[@"text"];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(260, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont appFontOfSize:14]}
                                     context:nil];
    
    CGFloat cellHeight = 38 + rect.size.height + 10;
    return cellHeight;
}

@end
