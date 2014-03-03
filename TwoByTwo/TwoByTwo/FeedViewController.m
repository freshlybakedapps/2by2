//
//  FeedViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedViewController.h"
#import "CameraViewController.h"
#import "PDPViewController.h"
#import "FeedCell.h"
#import "ThumbCell.h"
#import "FeedHeaderView.h"
#import "FeedProfileHeaderView.h"
#import "FeedFooterView.h"

static NSUInteger const kQueryBatchSize = 20;


@interface FeedViewController () <FeedCellDelegate, FeedHeaderViewDelegate>
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic) NSUInteger totalNumberOfObjects;
@property (nonatomic) NSUInteger queryOffset;
@property (nonatomic) BOOL showingFeed;
@property (nonatomic) BOOL showingDouble;
@end


@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.user) {
        self.title = self.user.username;
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedProfileHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedProfileHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FeedFooterView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellWithReuseIdentifier:@"FeedCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:@"ThumbCell"];
    
    
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
    if (self.type == FeedTypeFollowing || self.type == FeedTypeGlobal) {
        [self loadFollowers];
    }
    else {
        [self loadPhotos];
    }
}

- (void)loadFollowers
{
    PFQuery *query = [PFQuery queryWithClassName:@"Followers"];
    if ([PFUser currentUser]) {
        [query whereKey:@"userID" equalTo:[PFUser currentUser].objectId];
    }
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
            [query whereKey:@"user" notContainedIn:self.followers];
            [query whereKey:@"user_full" notContainedIn:self.followers];
            
            break;
            
        case FeedTypeFollowing: {
            PFQuery *userQuery = [PFQuery queryWithClassName:@"Photo"];
            [userQuery whereKey:@"user" containedIn:self.followers];
            
            PFQuery *userFullQuery = [PFQuery queryWithClassName:@"Photo"];
            [userFullQuery whereKey:@"user_full" containedIn:self.followers];
            
            query = [PFQuery orQueryWithSubqueries:@[userQuery,userFullQuery]];
            
            if(!self.showingDouble){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }
            
            break;
        }
            
        case FeedTypeYou: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", [PFUser currentUser], [PFUser currentUser]];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            
            if(!self.showingDouble){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }

            break;
        }
            
        case FeedTypeFriend: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", self.user, self.user];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            
            if(!self.showingDouble){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }
            
            
            break;
        }
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
        
        PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
        [query whereKey:@"notificationID" equalTo:object.objectId];
        
        if(date){
            [query whereKey:@"createdAt" greaterThan:date];
        }
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if(!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:NoficationDidUpdatePushNotificationCount object:self userInfo:@{NoficationUserInfoKeyCount:@(number)}];
            }
        }];
    }];
}


#pragma mark - Collection View

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10.0 : 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10.0 : 2.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.showingFeed) ? CGSizeMake(320, 410) : CGSizeMake(78.5, 78.5);
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
    
    if (!self.showingFeed) {
        ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
        cell.photo = self.objects[indexPath.row];
        return cell;
    }
    else {
        FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
        cell.photo = self.objects[indexPath.row];
        cell.delegate = self;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *photo = self.objects[indexPath.row];

    if (self.showingFeed && [photo.state isEqualToString:@"half"] && ![photo.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        CameraViewController *controller = [CameraViewController controller];
        controller.photo = photo;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        PDPViewController *controller = [PDPViewController controller];
        controller.photoID = photo.objectId;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (self.type) {
        case FeedTypeFriend:
        case FeedTypeYou:
            return CGSizeMake(0, [FeedProfileHeaderView headerHeightForType:self.type]);
            
        default:
            return CGSizeMake(0, [FeedHeaderView headerHeightForType:self.type]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (self.totalNumberOfObjects == 0) ? CGSizeMake(0, 80) : CGSizeMake(0, 1); // Setting CGSizeZero causes crash
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        switch (self.type) {
            case FeedTypeFriend:
            case FeedTypeYou: {
                FeedProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedProfileHeaderView" forIndexPath:indexPath];
                headerView.user = (self.type == FeedTypeFriend) ? self.user : nil;
                headerView.delegate = self;
                return headerView;
            }
                
            default: {
                FeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedHeaderView" forIndexPath:indexPath];
                headerView.type = self.type;
                headerView.delegate = self;
                return headerView;
            }
        }
    }
    else {
        FeedFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FeedFooterView" forIndexPath:indexPath];
        footerView.showingDouble = self.showingDouble;
        footerView.type = self.type;
        return footerView;
    }
    return nil;
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
    PDPViewController *controller = [PDPViewController controller];
    controller.photoID = photo.objectId;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - FeedHeaderViewDelegate

- (void)setShowingFeed:(BOOL)showingFeed
{
    _showingFeed = showingFeed;
    [self.collectionView reloadData];
}

- (void)setShowingDouble:(BOOL)showingDouble
{
    _showingDouble = showingDouble;
    self.objects = nil;
    [self.collectionView reloadData];
    [self loadPhotos];
}

- (void)updateHeaderHeight
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

@end
