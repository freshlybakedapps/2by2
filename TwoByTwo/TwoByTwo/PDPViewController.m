//
//  PDPViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PDPViewController.h"
#import "FeedViewController.h"
#import "CameraViewController.h"
#import "FeedCell.h"
#import "LikersCell.h"
#import "CommentCell.h"
#import "AddCommentCell.h"
#import "DAKeyboardControl.h"

typedef NS_ENUM(NSUInteger, CollectionViewSection) {
    CollectionViewSectionMain = 0,
    CollectionViewSectionLikers,
    CollectionViewSectionComments,
    CollectionViewSectionAddComment,
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
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellWithReuseIdentifier:@"FeedCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect rect = weakSelf.view.frame;
        rect.size.height = keyboardFrameInView.origin.y;
        weakSelf.view.frame = rect;
    }];
    
    // Load Data
    [self performPhotoQuery];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view removeKeyboardControl];
    [super viewDidDisappear:animated];
}


#pragma mark - Query

- (void)performPhotoQuery
{
    if (!self.photoID) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;

    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass];
    [query whereKey:PFObjectIDKey equalTo:self.photoID];
    [query includeKey:PFUserKey];
    [query includeKey:PFUserFullKey];
    
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

    PFQuery *query = [PFQuery queryWithClassName:PFCommentClass];
    [query whereKey:PFCommentIDKey equalTo:self.photoID];
    [query orderByAscending:PFCreatedAtKey];
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
            
        case CollectionViewSectionComments: {
            CGFloat height = [CommentCell heightForComment:self.comments[indexPath.item]];
            return CGSizeMake(320, height);
        }
            
        case CollectionViewSectionAddComment:
            default:
            return CGSizeMake(320, 60);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case CollectionViewSectionMain: {
            FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
            cell.shouldHaveDetailLink = NO;
            cell.photo = self.photo;
            cell.delegate = self;
            return cell;
        }
            
        case CollectionViewSectionLikers: {
            LikersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LikersCell" forIndexPath:indexPath];
            cell.likers = self.photo.likes;
            return cell;
        }
            
        case CollectionViewSectionComments: {
            CommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CommentCell" forIndexPath:indexPath];
            cell.comment = self.comments[indexPath.item];
            return cell;
        }
            
        case CollectionViewSectionAddComment:
        default: {
            __weak typeof(self) weakSelf = self;
            AddCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AddCommentCell" forIndexPath:indexPath];
            cell.photo = self.photo;
            cell.didSendComment = ^(PFObject *comment){
                [weakSelf.collectionView performBatchUpdates:^{
                    
                    NSIndexPath *commentIndexPath = [NSIndexPath indexPathForItem:weakSelf.comments.count inSection:CollectionViewSectionComments];
                    weakSelf.comments = [weakSelf.comments arrayByAddingObject:comment];
                    [weakSelf.collectionView insertItemsAtIndexPaths:@[commentIndexPath]];
                    
                    NSIndexPath *mainIndexPath = [NSIndexPath indexPathForItem:0 inSection:CollectionViewSectionMain];
                    weakSelf.photo.commentCount = [NSString stringWithFormat:@"%lu",(unsigned long)weakSelf.comments.count];
                    [weakSelf.collectionView reloadItemsAtIndexPaths:@[mainIndexPath]];

                } completion:^(BOOL finished) {
                    CGPoint bottomOffset = CGPointMake(0, weakSelf.collectionView.contentSize.height - weakSelf.collectionView.bounds.size.height);
                    [weakSelf.collectionView setContentOffset:bottomOffset animated:YES];
                }];
            };
            return cell;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == CollectionViewSectionMain && [self.photo.state isEqualToString:PFStateValueHalf] && ![self.photo.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        CameraViewController *controller = [CameraViewController controller];
        controller.photo = self.photo;
        [self presentViewController:controller animated:YES completion:nil];
    }
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
