//
//  ProfileContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "ProfileContainerCell.h"
#import "ProfileFeedHeaderView.h"
#import "UICollectionView+Addon.h"


@interface ProfileContainerCell ()
@end


@implementation ProfileContainerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.collectionView registerNibWithViewClass:[ProfileFeedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
    }
    return self;
}

- (PFQuery *)photoQuery
{
    PFUser *user = (self.user) ?: [PFUser currentUser];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", user, user];
    
    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass predicate:predicate];
    [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
    return query;
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 250.0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        ProfileFeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ProfileFeedHeaderView class]) forIndexPath:indexPath];
        headerView.user = self.user;
        headerView.delegate = self;
        return headerView;
    }
    else {
        FeedFooterView *footerView = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        
        if (self.user) {
            NSString *statement = (self.showingDouble)
            ? NSLocalizedString(@"This person has no double shots right now.", @"Feed footer message")
            : NSLocalizedString(@"This person has no single shots to double expose right now.", @"Feed footer message");
            
            NSString *invite = NSLocalizedString(@"This is a great time to invite new friends to join 2by2", @"Feed footer message");
            
            footerView.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", statement, invite];
        }
        else {
            footerView.textLabel.text = (self.showingDouble)
            ? NSLocalizedString(@"Not much going on here yet. Go to any single exposed photo and tap on it to create a double exposure.", @"Feed footer message")
            : NSLocalizedString(@"Not much going on here yet. Take a photo by tapping below.", @"Feed footer message");
        }
        return footerView;
    }
}

@end
