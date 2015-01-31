//
//  NotificationsContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NotificationsContainerCell.h"
#import "NotificationHeaderView.h"
#import "NotificationCell.h"
#import "UICollectionView+Addon.h"


@implementation NotificationsContainerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.collectionView registerNibWithViewClass:[NotificationHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
        [self.collectionView registerNibWithCellClass:[NotificationCell class]];
    }
    return self;
}

- (void)performQuery
{
    
    
    PFQuery *query = [PFQuery queryWithClassName:PFNotificationClass];
    [query whereKey:PFNotificationIDKey equalTo:[PFUser currentUser].objectId];
    [query orderByDescending:PFCreatedAtKey];
    
    __weak typeof(self) weakSelf = self;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.objects = [objects mutableCopy];
            [weakSelf.collectionView reloadData];
            
            NSLog(@"MMMM %lu", (unsigned long)weakSelf.objects.count);
        }
    }];
}


#pragma mark - Collection View

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *notification = self.objects[indexPath.row];
    NSString *text = notification[@"content"];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(260, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont appFontOfSize:16]}
                                     context:nil];
    
    CGFloat cellHeight = 38 + rect.size.height + 10;
    return CGSizeMake(320, cellHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NotificationCell class]) forIndexPath:indexPath];
    cell.notification = self.objects[indexPath.row];
    return cell;
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 50);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeZero;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        NotificationHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([NotificationHeaderView class]) forIndexPath:indexPath];
        return headerView;
    }
    else {
        return nil;
    }
}

@end
