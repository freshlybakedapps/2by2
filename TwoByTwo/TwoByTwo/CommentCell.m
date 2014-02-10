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
@property (nonatomic, weak) IBOutlet UILabel *commentLabel;
@end


@implementation CommentCell

- (void)setComment:(PFObject *)comment
{
    _comment = comment;

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=normal", comment[@"facebookId"]]];
    [self.avatarImageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) * 0.5;
    
    self.nameLabel.text = comment[@"username"];
    self.commentLabel.text = comment[@"text" ];
    self.dateLabel.text = [comment.createdAt timeAgoString];
    
    self.nameLabel.font = [UIFont appFontOfSize:14];
    self.commentLabel.font = [UIFont appFontOfSize:14];
    self.dateLabel.font = [UIFont appFontOfSize:14];
    
    self.nameLabel.textColor = [UIColor appGreenColor];
}

@end
