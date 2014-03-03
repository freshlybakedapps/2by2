//
//  PDPViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PDPViewController.h"
#import "FeedViewController.h"
#import "FeedCell.h"
#import "LikersCell.h"
#import "CommentCell.h"

typedef NS_ENUM(NSUInteger, CollectionViewSection) {
    CollectionViewSectionMain = 0,
    CollectionViewSectionLikers,
    CollectionViewSectionComments,
    CollectionViewSectionCount,
};


@interface PDPViewController () <FeedCellDelegate>
@property (nonatomic, strong) PFObject *photo;
@property (nonatomic, strong) NSArray *comments;
@end


@implementation PDPViewController

+ (instancetype)controller
{
    id controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PDPViewController"];
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Details";
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellWithReuseIdentifier:@"FeedCell"];

    // Load Data
    [self performPhotoQuery];
}


#pragma mark - Query

- (void)performPhotoQuery
{
    __weak typeof(self) weakSelf = self;

    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"objectId" equalTo:self.photoID];
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.photo = [objects lastObject];
            [weakSelf.collectionView reloadData];
            [weakSelf performCommentsQuery];
        }
        else {
            weakSelf.photo = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        [weakSelf.collectionView reloadData];
    }];
}

- (void)performCommentsQuery
{
    __weak typeof(self) weakSelf = self;

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"commentID" equalTo:self.photoID];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            weakSelf.comments = [objects mutableCopy];
            [weakSelf.collectionView reloadData];
        }
    }];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (self.photo) ? CollectionViewSectionCount : 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (section == CollectionViewSectionComments) ? self.comments.count : 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CollectionViewSectionMain:
            return CGSizeMake(320, 410);

        case CollectionViewSectionLikers:
            return CGSizeMake(320, (self.photo.likes.count) ? 70 : 1);
            
        case CollectionViewSectionComments:
        default: {
            CGFloat height = [CommentCell heightForComment:self.comments[indexPath.item]];
            return CGSizeMake(320, height);
        }
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CollectionViewSectionMain: {
            FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
            cell.photo = self.photo;
            cell.delegate = self;
            return cell;
        }
            
        case CollectionViewSectionLikers: {
            LikersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikersCell" forIndexPath:indexPath];
            cell.likers = self.photo.likes;
            return cell;
        }
            
        case CollectionViewSectionComments:
        default: {
            CommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CommentCell" forIndexPath:indexPath];
            cell.comment = self.comments[indexPath.item];
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}


#pragma mark - FeedCell Delegate

- (void)cell:(FeedCell *)cell showProfileForUser:(PFUser *)user
{
    FeedViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedViewController"];
    controller.type = FeedTypeFriend;
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cell:(FeedCell *)cell showCommentsForPhoto:(PFObject *)photo
{
}

@end
