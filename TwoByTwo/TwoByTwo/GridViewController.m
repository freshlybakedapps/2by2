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
    self.feedLayout.itemSize = CGSizeMake(300, 370);
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
    
    switch (self.type) {
        case FeedTypeYou:
        {
            //on FeedTypeYou we want to show all photos you started or finished
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", [PFUser currentUser], [PFUser currentUser]];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
        }
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
    
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
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
//    if (self.collectionView.collectionViewLayout == self.gridLayout) {
//        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SmallGridCell" forIndexPath:indexPath];
//        UIImageView *imageView = (id)[cell viewWithTag:10];
//        
//        PFObject *photo = self.objects[indexPath.row];
//        PFFile *file = ([photo.state isEqualToString:@"full"]) ? photo.imageFull : photo.imageHalf;
//        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            if (!error) {
//                UIImage *image = [UIImage imageWithData:data];
//                imageView.image = image;
//            }
//            else {
//                NSLog(@"getDataInBackgroundWithBlock: %@", error);
//            }
//        }];
//
//        return cell;
//    }
//    else {
        GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
        cell.photo = self.objects[indexPath.row];
        return cell;
//    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.collectionViewLayout == self.gridLayout) {
        [self.collectionView setCollectionViewLayout:self.feedLayout animated:YES];
//        [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
    }
    else {
        PFObject *photo = self.objects[indexPath.row];
        if (photo.showMap) {
            GridCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
            photo.showMap = NO;
            [cell showImageOrMapAnimated:YES];
        }
        else {
            if (self.type == FeedTypeSingle) {
                CameraViewController *controller = [CameraViewController controller];
                controller.photo = self.objects[indexPath.row];
                [self presentViewController:controller animated:YES completion:nil];
            }
            else {
                [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
//                [collectionView reloadItemsAtIndexPaths:[collectionView indexPathsForVisibleItems]];
            }
        }
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 80);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridHeaderView" forIndexPath:indexPath];
    
    return headerView;
}

@end
