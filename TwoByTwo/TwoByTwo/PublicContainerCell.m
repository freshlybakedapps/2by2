//
//  PublicContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PublicContainerCell.h"


@interface PublicContainerCell ()
@property (nonatomic, strong) NSArray *followers;
@end


@implementation PublicContainerCell

- (void)performQuery
{
    [self loadFollowersWithCompletion:^(NSArray *objects, NSError *error) {
        self.followers = objects;
        [self loadPhotosWithCompletion:nil];
    }];
}

- (PFQuery *)photoQuery
{
    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass];
    [query whereKey:PFStateKey equalTo:PFStateValueFull];
    [query whereKey:PFUserKey notContainedIn:self.followers];
    [query whereKey:PFUserFullKey notContainedIn:self.followers];
    return query;
}


@end
