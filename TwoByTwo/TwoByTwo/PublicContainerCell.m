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
    [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
    [query whereKey:PFUserKey notContainedIn:self.followers];
    [query whereKey:PFUserFullKey notContainedIn:self.followers];
    return query;
}


#pragma mark - Collection View Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];

    if (kind == UICollectionElementKindSectionHeader) {
        FeedHeaderView *headerView = (id)view;
        headerView.title = NSLocalizedString(@"PUBLIC PHOTOS", @"Feed title");
    }
    else {
        FeedFooterView *footerView = (id)view;
        
        NSString *statement = (self.showingDouble)
        ? NSLocalizedString(@"There are no double exposure photos right now.", @"Feed footer message")
        : NSLocalizedString(@"There are no single exposure photos right now.", @"Feed footer message");
        
        NSString *invite = NSLocalizedString(@"2by2 is more fun with friends and family, invite them to join.", @"Feed footer message");
        
        footerView.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", statement, invite];
    }
    
    return view;
}

@end
