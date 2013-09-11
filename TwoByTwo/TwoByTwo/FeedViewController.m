//
//  FeedViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"


@interface FeedViewController ()
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@end


@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    return cell;
}

@end
