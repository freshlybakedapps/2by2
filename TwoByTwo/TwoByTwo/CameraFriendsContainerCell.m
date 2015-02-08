//
//  CameraFriendsContainerCell.m
//  TwoByTwo
//
//  Created by Tuberts on 2/8/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import "CameraFriendsContainerCell.h"


@interface CameraFriendsContainerCell ()
@property (nonatomic, strong) NSArray *followers;
@end


@implementation CameraFriendsContainerCell

- (void)performQuery
{
    [self loadFollowersWithCompletion:^(NSArray *objects, NSError *error) {
        self.followers = objects;
        [self loadPhotosWithCompletion:nil];
    }];
}

- (PFQuery *)photoQuery
{
    PFQuery *userQuery = [PFQuery queryWithClassName:PFPhotoClass];
    [userQuery whereKey:PFUserKey containedIn:self.followers];
    
    PFQuery *userFullQuery = [PFQuery queryWithClassName:PFPhotoClass];
    [userFullQuery whereKey:PFUserFullKey containedIn:self.followers];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[userQuery, userFullQuery]];
    [query whereKey:PFStateKey equalTo:PFStateValueHalf];
    return query;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 1);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 1);
}









@end
