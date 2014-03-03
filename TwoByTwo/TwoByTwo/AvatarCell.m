//
//  AvatarCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "AvatarCell.h"
#import "UIImageView+AFNetworking.h"


@interface AvatarCell ()
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@end


@implementation AvatarCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.layer.cornerRadius = CGRectGetWidth(self.imageView.frame) * 0.5;
}

- (void)setUserID:(NSString *)userID
{
    _userID = userID;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:userID];
    query.limit = 1;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            PFObject *user = objects[0];
            NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=square", user[@"facebookId"]]];
            [self.imageView setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultUserImage"]];
        }
    }];
}

@end
