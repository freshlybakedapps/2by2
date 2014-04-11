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



@interface CommentCell ()
@property (nonatomic, weak) IBOutlet UIImageView *avatarImageView;
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet AMAttributedHighlightLabel *commentLabel;
@end


@implementation CommentCell

- (void)setComment:(PFObject *)comment
{
    _comment = comment;

    NSURL *URL = [NSURL URLWithFacebookUserID:comment.facebookID];
    
    if(comment.twitterProfileImageURL && ![comment.twitterProfileImageURL isEqualToString:@""]){
        URL = [NSURL URLWithString:comment.twitterProfileImageURL];
    }
    
    [self.avatarImageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) * 0.5;
    
    self.nameLabel.text = comment[@"username"];
    //self.commentLabel.text = comment[@"text" ];
    self.dateLabel.text = [comment.createdAt timeAgoString];
    
    self.nameLabel.font = [UIFont appFontOfSize:14];
    self.commentLabel.font = [UIFont appFontOfSize:14];
    self.dateLabel.font = [UIFont appFontOfSize:14];
    
    self.nameLabel.textColor = [UIColor appGreenColor];
    
    
    //self.commentLabel.textColor = [UIColor lightGrayColor];
    self.commentLabel.mentionTextColor = [UIColor appGreenColor];
    self.commentLabel.hashtagTextColor = [UIColor appGreenColor];
    self.commentLabel.linkTextColor = [UIColor appGreenColor];
    //self.commentLabel.selectedMentionTextColor = [UIColor blackColor];
    //self.commentLabel.selectedHashtagTextColor = [UIColor blackColor];
    //self.commentLabel.selectedLinkTextColor = UIColorFromRGB(0x4099FF);
    
    
    self.commentLabel.delegate = self;
    self.commentLabel.userInteractionEnabled = YES;
    self.commentLabel.numberOfLines = 0;
    self.commentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.commentLabel setString:comment[@"text" ]];
    
}

- (void)selectedMention:(NSString *)string {
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selected" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    */
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    if ([PFUser currentUser]) {
        [query whereKey:@"username" equalTo:@"jtubert";
    }
    [query selectKeys:@[PFFollowingUserIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.followers = [objects bk_map:^id(id object) {
                NSString *userID = object[PFFollowingUserIDKey];
                PFUser *user = [PFUser objectWithoutDataWithObjectId:userID];
                return user;
            }];
            [self loadPhotos];
        }
        else {
            NSLog(@"loadFollowers error: %@", error);
        }
    }];

}
- (void)selectedHashtag:(NSString *)string {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Selected" message:string delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
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
