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
#import "GridHeaderView.h"
#import "MainViewController.h"
#import "CommentsViewController.h"

static NSUInteger const kQueryBatchSize = 20;


@interface GridViewController () <GridCellDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *gridLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *feedLayout;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic) NSUInteger totalNumberOfObjects;
@property (nonatomic) NSUInteger queryOffset;
@end


@implementation GridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Setup Layouts
    self.gridLayout = [UICollectionViewFlowLayout new];
    self.gridLayout.itemSize = CGSizeMake(78.5, 78.5);
    self.gridLayout.minimumInteritemSpacing = 2;
    self.gridLayout.minimumLineSpacing = 2;
    self.gridLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.gridLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.feedLayout = [UICollectionViewFlowLayout new];
    self.feedLayout.itemSize = CGSizeMake(320, 370);
    self.feedLayout.minimumInteritemSpacing = 10;
    self.feedLayout.minimumLineSpacing = 10;
    self.feedLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.feedLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView.collectionViewLayout = self.gridLayout;
    
    
    // Load Data
    [self performQuery];
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    /*
     Source:
     http://stackoverflow.com/questions/19038949/content-falls-beneath-navigation-bar-when-embedded-in-custom-container-view-cont
     */

    if ([parent isKindOfClass:[MainViewController class]] && self.navigationController.topViewController == parent) {
        CGFloat top = parent.topLayoutGuide.length;
        CGFloat bottom = parent.bottomLayoutGuide.length;
        if (self.collectionView.contentInset.top != top) {
            UIEdgeInsets newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
            self.collectionView.contentInset = newInsets;
            self.collectionView.scrollIndicatorInsets = newInsets;
        }
    }
    else {
        [super didMoveToParentViewController:parent];
    }
}


#pragma mark - Query

- (void)performQuery
{
    if (self.type == FeedTypeFollowing) {
        [self loadFollowers];
    }
    else {
        [self loadPhotos];
    }
}

- (void)loadFollowers
{
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    [query whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    [query selectKeys:@[@"followingUserID"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.followers = [objects bk_map:^id(id object) {
                NSString *userID = object[@"followingUserID"];
                PFUser *user = [PFUser objectWithoutDataWithObjectId:userID];
                return user;
            }];
            [self loadPhotos];
        }
        else {
            NSLog(@"loadFollowers error: %@", error);
        }
    }];
    
}

- (void)loadPhotos
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    
    switch (self.type) {
        case FeedTypeSingle:
            [query whereKey:@"state" equalTo:@"half"];
            [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
            break;

        case FeedTypeGlobal:
        default:
            [query whereKey:@"state" equalTo:@"full"];
            break;

        case FeedTypeFollowing: {
            PFQuery *userQuery = [PFQuery queryWithClassName:@"Photo"];
            [userQuery whereKey:@"user" containedIn:self.followers];
            
            PFQuery *userFullQuery = [PFQuery queryWithClassName:@"Photo"];
            [userFullQuery whereKey:@"user_full" containedIn:self.followers];
            
            query = [PFQuery orQueryWithSubqueries:@[userQuery,userFullQuery]];
            break;
        }
            
        case FeedTypeYou: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", [PFUser currentUser], [PFUser currentUser]];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            break;
        }

        case FeedTypeFriend: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", self.user, self.user];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            break;
        }

        case FeedTypePDP:
            self.collectionView.collectionViewLayout = self.feedLayout;
            [query whereKey:@"objectId" equalTo:self.photoID];
            break;
    }
    
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    [query orderByDescending:@"createdAt"];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {

        self.totalNumberOfObjects = number;
        query.limit= kQueryBatchSize;
        query.skip = self.objects.count;
        [query setCachePolicy:kPFCachePolicyNetworkElseCache];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                if (!self.objects) {
                    self.objects = [NSMutableArray array];
                }
                [self.collectionView performBatchUpdates:^{
                    NSUInteger count = self.objects.count;
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    for (NSUInteger i = count; i < count + objects.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    [self.objects addObjectsFromArray:objects];
                    [self.collectionView insertItemsAtIndexPaths:indexPaths];
                } completion:nil];
            }
            else {
                self.objects = nil;
                [self.collectionView reloadData];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            [self loadNotifications];
        }];
    }];
}

- (void)loadNotifications
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSDate *date = object[@"notificationWasAccessed"];
        NSLog(@"notificationWasAccessed: %@", date);

        PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
        [query whereKey:@"notificationID" equalTo:object.objectId];
        [query whereKey:@"createdAt" greaterThan:date];
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"notification count: %d", number);
            [[AppDelegate delegate].mainNavigationBar updateNotificationCount:number];
        }];
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
    if (indexPath.row == self.objects.count - 1 && self.objects.count < self.totalNumberOfObjects) {
        [self performQuery];
    }
    
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    cell.photo = self.objects[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.collectionView.collectionViewLayout == self.gridLayout) {
        [self.collectionView setCollectionViewLayout:self.feedLayout animated:YES];
    }
    else {
        if (self.type == FeedTypeSingle) {
            CameraViewController *controller = [CameraViewController controller];
            controller.photo = self.objects[indexPath.row];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else if (self.type != FeedTypePDP) {
            [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
        }
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (self.type) {
        case FeedTypeFriend:
        case FeedTypeYou:
            return CGSizeMake(0, 175);
            
        default:
           return CGSizeZero;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        GridHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridHeaderView" forIndexPath:indexPath];
        headerView.user = (self.type == FeedTypeFriend) ? self.user : nil;
        return headerView;
    }
    return nil;
}


#pragma mark - GridCell Delegate

- (void)cell:(GridCell *)cell showProfileForUser:(PFUser *)user
{
    GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
    controller.type = FeedTypeFriend;
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cell:(GridCell *)cell showCommentsForPhoto:(PFObject *)photo
{
    CommentsViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    controller.commentID = photo.objectId;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
