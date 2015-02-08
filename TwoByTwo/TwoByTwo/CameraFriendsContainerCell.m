//
//  CameraFriendsContainerCell.m
//  TwoByTwo
//
//  Created by Tuberts on 2/8/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import "CameraFriendsContainerCell.h"
#import "UICollectionView+Addon.h"
#import "CameraFriendStrangerHeaderView.h"
#import "CameraViewController.h"
#import "MainViewController.h"


@interface CameraFriendsContainerCell ()
@property (nonatomic, strong) NSArray *followers;
@end


@implementation CameraFriendsContainerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.collectionView registerNibWithViewClass:[CameraFriendStrangerHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
        
    }
    return self;
}


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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *photo = self.objects[indexPath.row];
    [self.cameraViewController friendsPhotoSelected:photo];
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(320, 100);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 1);
}

#pragma mark - Collection View Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        CameraFriendStrangerHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([CameraFriendStrangerHeaderView class]) forIndexPath:indexPath];
        
        return headerView;
    }
    else {
        FeedFooterView *footerView = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        
        NSString *statement = (self.showingDouble)
        ? NSLocalizedString(@"There are no double exposure photos right now.", @"Feed footer message")
        : NSLocalizedString(@"There are no single exposure photos right now.", @"Feed footer message");
        
        NSString *invite = NSLocalizedString(@"2by2 is more fun with friends and family, invite them to join.", @"Feed footer message");
        
        footerView.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", statement, invite];
        return footerView;
    }
}










@end
