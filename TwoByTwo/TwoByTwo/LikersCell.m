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
@property (nonatomic, weak) PFUser *user;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self) weakSelf = self;
    
    NSString* userID = self.likers[indexPath.row];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PFObjectIDKey equalTo:userID];
    query.limit = 1;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count > 0) {
            PFUser *user = objects[0];
            [weakSelf.delegate cell:weakSelf showProfileForUser:user];
        }
    }];
}


@end
