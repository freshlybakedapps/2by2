//
//  PopularContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PopularContainerCell.h"
#import "PopularFeedHeaderView.h"
#import "UICollectionView+Addon.h"


@implementation PopularContainerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.collectionView registerNibWithViewClass:[PopularFeedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
    }
    return self;
}

- (PFQuery *)photoQuery
{
    //TODO: what should the query be?
    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass];
    [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
    [query whereKey:@"featured" equalTo:[NSNumber numberWithBool:YES]];
    return query;
}


#pragma mark - Collection View Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        PopularFeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PopularFeedHeaderView class]) forIndexPath:indexPath];
        headerView.title = NSLocalizedString(@"POPULAR PHOTOS", @"Feed title");
        headerView.delegate = self;
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
