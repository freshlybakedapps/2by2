//
//  LikersCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/2/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "LikersCell.h"
#import "AvatarCell.h"


@interface LikersCell ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end


@implementation LikersCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.titleLabel.font = [UIFont appFontOfSize:14];
}

- (void)setLikers:(NSArray *)likers
{
    _likers = likers;
    [self.collectionView reloadData];
}

#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.likers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AvatarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AvatarCell" forIndexPath:indexPath];
    cell.userID = self.likers[indexPath.row];
    return cell;
}

@end
