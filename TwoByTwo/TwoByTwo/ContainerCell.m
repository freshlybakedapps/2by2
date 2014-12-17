//
//  ContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "ContainerCell.h"
#import "FeedCell.h"
#import "ThumbCell.h"
#import "CameraViewController.h"
#import "PDPViewController.h"
#import "UICollectionView+Addon.h"
#import "MainViewController.h"

static NSUInteger const kQueryBatchSize = 20;


@interface ContainerCell ()
@property (nonatomic) NSUInteger totalNumberOfObjects;
@property (nonatomic) NSUInteger queryOffset;
@end


@implementation ContainerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performQuery) name:NoficationShouldReloadPhotos object:nil];
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;

        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.dataSource = self;
        collectionView.delegate = self;
        [collectionView registerNibWithViewClass:[FeedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
        [collectionView registerNibWithViewClass:[FeedFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter];
        [collectionView registerNibWithCellClass:[FeedCell class]];
        [collectionView registerNibWithCellClass:[ThumbCell class]];
        [self addSubview:collectionView];
        self.collectionView = collectionView;
        
        _showingDouble = YES;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Type

- (ContentType)type
{
    // Subclass to override this.
    return 0;
}


#pragma mark - Query

- (void)performQuery
{
    NSLog(@"xxxxxxxxx");
    // Default behavoir. Subclass to override this.
    [self loadPhotosWithCompletion:nil];
}

- (PFQuery *)photoQuery
{
    // Subclass to override this.
    return nil;
}

- (void)loadPhotosWithCompletion:(PFArrayResultBlock)completion
{
    NSLog(@"loadPhotosWithCompletion 1");
    
    PFQuery *query = [self photoQuery];
    if (!query) {
        return;
    }
    
    NSLog(@"loadPhotosWithCompletion 2");
    
    [query includeKey:PFUserKey];
    [query includeKey:PFUserFullKey];
    [query orderByDescending:PFCreatedAtKey];
    
    @weakify(self);
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        @strongify(self);

        NSLog(@"loadPhotosWithCompletion 3");
        
        self.totalNumberOfObjects = number;
        query.limit= kQueryBatchSize;
        query.skip = self.objects.count;
        
        //query.cachePolicy = kPFCachePolicyNetworkElseCache;
        
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
                    
                    //save object for offline
                    //[PFObject pinAllInBackground:objects];
                    
                } completion:nil];
            }
            else {
                self.objects = nil;
                [self.collectionView reloadData];
                [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                  otherButtonTitles:nil] show];
            }
            
            if (completion) completion(objects, error);
        }];
    }];
}

- (void)loadFollowersWithCompletion:(PFArrayResultBlock)completion
{
    if (![PFUser currentUser]) {
        NSLog(@"No current user!");
        return;
    }
    
    NSLog(@"loadFollowersWithCompletion");
    
    PFQuery *query = [PFQuery queryWithClassName:PFFollowersClass];
    [query whereKey:PFUserIDKey equalTo:[PFUser currentUser].objectId];
    [query selectKeys:@[PFFollowingUserIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            NSArray *followers = [objects bk_map:^id(id object) {
                NSString *userID = object[PFFollowingUserIDKey];
                PFUser *user = [PFUser objectWithoutDataWithObjectId:userID];
                return user;
            }];
            if (completion) completion(followers, nil);
        }
        else {
            NSLog(@"loadFollowers error: %@", error);
            if (completion) completion(nil, error);
        }
    }];
}

- (void)loadNotificationsWithCompletion:(PFIntegerResultBlock)completion
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        PFQuery *query = [PFQuery queryWithClassName:PFNotificationClass];
        [query whereKey:PFNotificationIDKey equalTo:object.objectId];
        
        NSDate *date = object.notificationWasAccessed;
        if (date){
            [query whereKey:PFCreatedAtKey greaterThan:date];
        }
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if (!error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NoficationDidUpdatePushNotificationCount object:nil userInfo:@{NoficationUserInfoKeyCount:@(number)}];
            }
            if (completion) completion(number, error);
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
    //NSLog(@"%lu %lu",(unsigned long)self.objects.count,(unsigned long)self.totalNumberOfObjects);
    
    
    if (indexPath.row == self.objects.count - 1 && self.objects.count < self.totalNumberOfObjects) {
        
        [self performQuery];
    }
    
    if (!self.showingFeed) {
        ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ThumbCell class]) forIndexPath:indexPath];
        cell.photo = self.objects[indexPath.row];
        return cell;
    }
    else {
        FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FeedCell class]) forIndexPath:indexPath];
        cell.shouldHaveDetailLink = YES;
        cell.photo = self.objects[indexPath.row];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *photo = self.objects[indexPath.row];
    
    if (self.showingFeed && [photo.state isEqualToString:PFStateValueHalf] && ![photo.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        CameraViewController *controller = [CameraViewController controller];
        controller.photo = photo;
        [[MainViewController currentController] presentViewController:controller animated:YES completion:nil];
    }
    else {
        NSString* photoID = photo[@"photoID"];
        
        PDPViewController *controller = [PDPViewController controller];
        
        if(photoID){
            controller.photoID = photoID;
        }else{
            controller.photoID = photo.objectId;
        }
        
        [[MainViewController currentController].navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 80);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (self.totalNumberOfObjects == 0){
        return CGSizeMake(0, 300);
    }
    else {
        return CGSizeMake(0, 1); // returning CGSizeZero causes crash
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        FeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([FeedHeaderView class]) forIndexPath:indexPath];
        headerView.delegate = self;
        return headerView;
    }
    else {
        FeedFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass([FeedFooterView class]) forIndexPath:indexPath];
        return footerView;
    }
    return nil;
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
    [self loadPhotosWithCompletion:nil];
}

- (void)updateHeaderHeight
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

@end
