//
//  GridViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridViewController.h"
#import "GridCell.h"
#import "CameraViewController.h"


@interface GridViewController ()
@property (nonatomic, strong) UICollectionViewFlowLayout *gridLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *feedLayout;
@property (nonatomic, strong) NSArray *objects;
@end


@implementation GridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gridLayout = [UICollectionViewFlowLayout new];
    self.gridLayout.itemSize = CGSizeMake(77, 77);
    self.gridLayout.minimumInteritemSpacing = 2;
    self.gridLayout.minimumLineSpacing = 2;
    self.gridLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    self.gridLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.feedLayout = [UICollectionViewFlowLayout new];
    self.feedLayout.itemSize = CGSizeMake(300, 300);
    self.feedLayout.minimumInteritemSpacing = 10;
    self.feedLayout.minimumLineSpacing = 10;
    self.feedLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.feedLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView.collectionViewLayout = self.gridLayout;
    [self performQuery];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    /*
     Source: 
     http://stackoverflow.com/questions/19038949/content-falls-beneath-navigation-bar-when-embedded-in-custom-container-view-cont
     */

    if (parent) {
        CGFloat top = parent.topLayoutGuide.length;
        CGFloat bottom = parent.bottomLayoutGuide.length;
        
        if (self.collectionView.contentInset.top != top) {
            UIEdgeInsets newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
            self.collectionView.contentInset = newInsets;
            self.collectionView.scrollIndicatorInsets = newInsets;
        }
    }
}


#pragma mark - Query

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    
    switch (self.type) {
        case FeedTypeYou:
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            break;
            
        case FeedTypeSingle:
            [query whereKey:@"state" equalTo:@"half"];
            [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
            break;
            
        case FeedTypeGlobal:
        default:
            [query whereKey:@"state" equalTo:@"full"];
            break;
    }
    
    [query orderByDescending:@"updatedAt"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {
            self.objects = objects;
        }
        else {
            self.objects = @[];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
    }];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    PFObject *object = self.objects[indexPath.row];
    cell.object = object;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.collectionViewLayout == self.gridLayout) {
        [self.collectionView setCollectionViewLayout:self.feedLayout animated:YES];
    }
    else {
//        [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
        
        CameraViewController *controller = [CameraViewController controller];
        controller.object = self.objects[indexPath.row];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

@end
