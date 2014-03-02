//
//  GridViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridViewController.h"
#import "FeedCell.h"
#import "CameraViewController.h"
#import "GridProfileHeaderView.h"
#import "GridTitleHeaderView.h"
#import "MainViewController.h"
#import "CommentsViewController.h"
#import "GridFooterView.h"
#import "PDPViewController.h"
#import "ThumbCell.h"

static NSUInteger const kQueryBatchSize = 20;

static NSUInteger const headerSmall = 81;//36
static NSUInteger const headerLarge = 165;//113


@interface GridViewController () <FeedCellDelegate>
//@property (nonatomic, strong) UICollectionViewFlowLayout *gridLayout;
//@property (nonatomic, strong) UICollectionViewFlowLayout *feedLayout;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic) NSUInteger totalNumberOfObjects;
@property (nonatomic) NSUInteger queryOffset;
@property (nonatomic, strong) NSString *singleOrDouble;
@property (nonatomic) BOOL showingFeed;
@end


@implementation GridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString* keyStoreValue = [NSString stringWithFormat:@"messageWasSeen_%lu",(unsigned long)self.type];
    //[[NSUbiquitousKeyValueStore defaultStore] removeObjectForKey:keyStoreValue];
    //[[NSUbiquitousKeyValueStore defaultStore] synchronize];
    
    if(![[NSUbiquitousKeyValueStore defaultStore] stringForKey:keyStoreValue]){
        self.headerSize = headerLarge;
    }else{
        self.headerSize = headerSmall;
    }
    
    self.singleOrDouble = @"single";
    
    if(self.type == FeedTypePDP){
        self.title = @"Details";
        self.headerSize = 0;
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"GridTitleHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridTitleHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"GridProfileHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridProfileHeaderView"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"GridFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GridFooterView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellWithReuseIdentifier:@"FeedCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:@"ThumbCell"];
    
    // Setup Layouts
//    self.gridLayout = [UICollectionViewFlowLayout new];
//    self.gridLayout.itemSize = CGSizeMake(78.5, 78.5);
//    self.gridLayout.minimumInteritemSpacing = 2;
//    self.gridLayout.minimumLineSpacing = 2;
//    self.gridLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.gridLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    
//    self.feedLayout = [UICollectionViewFlowLayout new];
//    self.feedLayout.itemSize = CGSizeMake(320, 410);
//    self.feedLayout.minimumInteritemSpacing = 10;
//    self.feedLayout.minimumLineSpacing = 10;
//    self.feedLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.feedLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//    
//    self.collectionView.collectionViewLayout = self.gridLayout;
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
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


- (void) toggleGridFeed
{
//    if(self.collectionView.collectionViewLayout == self.gridLayout){
//        self.collectionView.collectionViewLayout = self.feedLayout;
////        [self.collectionView setCollectionViewLayout:self.feedLayout animated:NO];
//    }else{
//        self.collectionView.collectionViewLayout = self.gridLayout;
////        [self.collectionView setCollectionViewLayout:self.gridLayout animated:NO];
//    }
    self.showingFeed = !self.showingFeed;
    [self.collectionView reloadData];
    
    
    //not sure why 64 but without this contentOffset it doesn't scroll to the top
    self.collectionView.contentOffset = CGPointMake(0, -64.0);
}

- (void) toggleSingleDouble{
    if([self.singleOrDouble isEqualToString:@"single"]){
        //NSLog(@"single");
        self.singleOrDouble = @"double";
    }else{
        //NSLog(@"double");
        self.singleOrDouble = @"single";
    }
    
    self.objects = nil;
    [self.collectionView reloadData];
    
    [self loadPhotos];
    
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
    if([PFUser currentUser]){
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
            
            if([self.singleOrDouble isEqualToString:@"single"]){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }
            
            break;
        }
            
        case FeedTypeYou: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", [PFUser currentUser], [PFUser currentUser]];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            
            if([self.singleOrDouble isEqualToString:@"single"]){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }

            break;
        }
            
        case FeedTypeFriend: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", self.user, self.user];
            query = [PFQuery queryWithClassName:@"Photo" predicate:predicate];
            
            if([self.singleOrDouble isEqualToString:@"single"]){
                [query whereKey:@"state" equalTo:@"half"];
            }else{
                [query whereKey:@"state" equalTo:@"full"];
            }
            
            
            break;
        }
            
        case FeedTypePDP:
//            self.collectionView.collectionViewLayout = self.feedLayout;
            self.showingFeed = YES;
            
            if(self.photoID){
                [query whereKey:@"objectId" equalTo:self.photoID];
            }
            break;
    }
    
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    [query orderByDescending:@"createdAt"];
    
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        GridFooterView* footer = (GridFooterView*)[self.collectionView viewWithTag:888];
        
        if(footer && number < 1){
            footer.hidden = NO;
        }
        
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
        //NSLog(@"notificationWasAccessed: %@", date);
        
        PFQuery *query = [PFQuery queryWithClassName:@"Notification"];
        [query whereKey:@"notificationID" equalTo:object.objectId];
        
        if(date){
            [query whereKey:@"createdAt" greaterThan:date];
        }
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if(!error){
                //NSLog(@"notification count: %d", number);
                [[NSNotificationCenter defaultCenter] postNotificationName:NoficationDidUpdatePushNotificationCount object:self userInfo:@{NoficationUserInfoKeyCount:@(number)}];
            }
        }];
    }];
}


#pragma mark - Collection View
//self.gridLayout.itemSize = CGSizeMake(78.5, 78.5);
//self.gridLayout.minimumInteritemSpacing = 2;
//self.gridLayout.minimumLineSpacing = 2;
//self.gridLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//self.gridLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
//
//self.feedLayout = [UICollectionViewFlowLayout new];
//self.feedLayout.itemSize = CGSizeMake(320, 410);
//self.feedLayout.minimumInteritemSpacing = 10;
//self.feedLayout.minimumLineSpacing = 10;
//self.feedLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//self.feedLayout.scrollDirection = UICollectionViewScrollDirectionVertical;

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10 : 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10 : 2;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    
//}
//
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.showingFeed) ? CGSizeMake(320, 410) : CGSizeMake(78.5, 78.5);
}

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
    
    id header;
    
    if(self.type == FeedTypeFriend || self.type == FeedTypeYou) {
        header = (GridProfileHeaderView*)[self.collectionView viewWithTag:777];
    }else{
        header = (GridTitleHeaderView*)[self.collectionView viewWithTag:999];
    }
    
    if (!self.showingFeed) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(320, 410);
        layout.minimumInteritemSpacing = 10;
        layout.minimumLineSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        PFObject *photo = self.objects[indexPath.row];
        PDPViewController *controller = [[PDPViewController alloc] initWithCollectionViewLayout:layout];
        controller.photoID = photo.objectId;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else {
        PFObject *photo = self.objects[indexPath.row];
        if([photo.state isEqualToString:@"half"] && ![photo.user.objectId isEqualToString:[PFUser currentUser].objectId]){
            CameraViewController *controller = [CameraViewController controller];
            controller.photo = self.objects[indexPath.row];
            [self presentViewController:controller animated:YES completion:nil];
        }
        else if (self.type != FeedTypePDP) {
//            [self.collectionView setCollectionViewLayout:self.gridLayout animated:YES];
//            [header toggleGridFeed];
        }
        
        /*
         if (self.type == FeedTypeSingle) {
         CameraViewController *controller = [CameraViewController controller];
         controller.photo = self.objects[indexPath.row];
         [self presentViewController:controller animated:YES completion:nil];
         }
         */
        
        
        
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (self.type) {
        case FeedTypeFriend:
        case FeedTypeYou:
            return CGSizeMake(0, 225);
            
        default:
            return CGSizeMake(0, self.headerSize);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(0, 80);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"self.type %u",self.type);
    if (kind == UICollectionElementKindSectionHeader) {
        switch (self.type) {
            case FeedTypeFriend:
            case FeedTypeYou: {
                GridProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridProfileHeaderView" forIndexPath:indexPath];
                headerView.user = (self.type == FeedTypeFriend) ? self.user : nil;
                headerView.tag = 777;
                headerView.controller = self;
                
                return headerView;
            }
                
            default: {
                GridTitleHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GridTitleHeaderView" forIndexPath:indexPath];
                
                headerView.tag = 999;
                headerView.controller = self;
                headerView.type = self.type;
                
                
                
                return headerView;
            }
        }

    }else{
        
            GridFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"GridFooterView" forIndexPath:indexPath];
            
            footerView.tag = 888;
            footerView.singleOrDouble = self.singleOrDouble;
            footerView.type = self.type;
            footerView.count = self.objects.count;
            
            footerView.hidden = YES;
            
            return footerView;
        
    }
    return nil;
}


#pragma mark - FeedCell Delegate

- (void)cell:(FeedCell *)cell showProfileForUser:(PFUser *)user
{
    GridViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"GridViewController"];
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
