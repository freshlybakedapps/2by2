//
//  PopularContainerCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "PopularContainerCell.h"
#import "PopularFeedHeaderView.h"
#import "UICollectionView+Addon.h"
#import "FeedCell.h"
#import "ThumbCell.h"
#import "NSMutableArray+Shuffling.h"

#import "TwoByTwo-Swift.h"


@interface PopularContainerCell ()
@property (nonatomic) NSUInteger totalNumberOfObjects;

@end



@implementation PopularContainerCell



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.collectionView registerNibWithViewClass:[PopularFeedHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader];
        
        
        SwiftTest* t = [SwiftTest new];
        NSLog(@"test: %@",[t helloWorldSwift]);
        
        
    }
    return self;
}

- (PFQuery *)photoQuery
{
    
    //TODO: what should the query be?
    PFQuery *query = [PFQuery queryWithClassName:PFPhotoClass];
    [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
    [query whereKey:@"featured" equalTo:[NSNumber numberWithBool:YES]];
    return query;
    
    
    /*
    NSMutableArray *arr = [NSMutableArray new];
    int requestCount = 25;
    PFQuery *query1;
    PFQuery *query2;
    
    for (int i=0; i<requestCount; i++) {
        query1 = [PFQuery queryWithClassName:PFPhotoClass];
        [query1 whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
        [query1 whereKey:@"featured" equalTo:[NSNumber numberWithBool:YES]];
        
        int r = floor(arc4random_uniform(20));
        
        query1.skip = r;
        query1.limit = 1;
        
        
        
        [arr addObject:query1];
    }
    
    PFQuery *randomQuery = [PFQuery orQueryWithSubqueries:[arr arrayByAddingObjectsFromArray:arr]];
    
    NSLog(@"%@",randomQuery);
    
    return randomQuery;
    */
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
        query.limit= 24;
        
        
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
                    
                    NSMutableArray* shuffledObjects = [NSMutableArray arrayWithArray:objects];
                    
                    [shuffledObjects shuffle];
                    
                    [self.objects addObjectsFromArray:shuffledObjects];
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

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
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





#pragma mark - Collection View Header

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        PopularFeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([PopularFeedHeaderView class]) forIndexPath:indexPath];
        headerView.title = NSLocalizedString(@"POPULAR PHOTOS", @"Feed title");
        headerView.delegate = self;
       return headerView;
    }
    else {
        FeedFooterView *footerView = (id)[super collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
        
        NSString *statement = (self.showingDouble)
        ? NSLocalizedString(@"There are no double exposure photos right now.", @"Feed footer message")
        : NSLocalizedString(@"There are no single exposure photos right now.", @"Feed footer message");
        
        NSString *invite = NSLocalizedString(@"2by2 is more fun with friends and family, invite them to join.", @"Feed footer message");
        
        footerView.textLabel.text = [NSString stringWithFormat:@"%@\n\n%@", statement, invite];
        return footerView;
    }
}

@end
