//
//  FriendsContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "FriendsContainerCell.h"


@interface FriendsContainerCell ()
@property (nonatomic, strong) NSArray *followers;
@end


@implementation FriendsContainerCell

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
    [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
    return query;
}


#pragma mark - Collection View Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    
    if (kind == UICollectionElementKindSectionHeader) {
        FeedHeaderView *headerView = (id)view;
        headerView.title = NSLocalizedString(@"FRIENDS PHOTOS", @"Feed title");
    }
    else {
        FeedFooterView *footerView = (id)view;
        
        NSString *statement = (self.showingDouble)
        ? NSLocalizedString(@"There are no double exposure photos from your friends right now.", @"Feed footer message")
        : NSLocalizedString(@"There are no single exposure photos from your friends right now.", @"Feed footer message");
        
        NSString *invite = NSLocalizedString(@"2by2 is more fun with friends and family, invite them to join", @"Feed footer message");
        
        footerView.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", statement, invite];
    }
    
    return view;
}

@end
