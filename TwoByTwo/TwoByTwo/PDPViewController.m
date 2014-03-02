//
//  PDPViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 3/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PDPViewController.h"
#import "FeedCell.h"
#import "CommentsViewController.h"
#import "FeedViewController.h"

typedef NS_ENUM(NSUInteger, CollectionViewSection) {
    CollectionViewSectionMain = 0,
    CollectionViewSectionLike,
    CollectionViewSectionComment,
    CollectionViewSectionCount,
};


@interface PDPViewController ()
@property (nonatomic, strong) PFObject *photo;
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
    [self performQuery];
}


#pragma mark - Query

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"objectId" equalTo:self.photoID];
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.photo = [objects lastObject];
            [self.collectionView reloadData];
        }
        else {
            self.photo = nil;
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        [self.collectionView reloadData];
    }];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return (self.photo) ? 1 : 0; //CollectionViewSectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return (section == CollectionViewSectionComment) ? 1 : 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.photo = self.photo;
    cell.delegate = self;
    return cell;
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
    CommentsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    controller.commentID = photo.objectId;
    controller.photo = photo;//self.photo.commentCount
    [self presentViewController:controller animated:YES completion:nil];
}

@end
