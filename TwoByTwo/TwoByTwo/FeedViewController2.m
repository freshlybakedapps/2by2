//
//  FeedViewController2
//
//
//  Created by John Tubert on 3/4/13.
//  Copyright (c) 2013 John Tubert. All rights reserved.
//

#import "FeedViewController2.h"
#import "FeedCell.h"
#import "CameraViewController.h"

@implementation FeedViewController2


@synthesize lastRefresh, currentSection;

NSString *const FeedViewControllerLastRefreshKey    = @"com.jtubert.2by2.userDefaults.FeedViewController2.lastRefresh";



#pragma mark - viewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSegmentChange:) name:@"segmentChanged" object:nil];
    
    if (![PFUser currentUser]) {
        
    }
    
    lastRefresh = [[NSUserDefaults standardUserDefaults] objectForKey:FeedViewControllerLastRefreshKey];
}

- (void) onSegmentChange:(NSNotification*)notification{
    UISegmentedControl* segment = (UISegmentedControl*) [notification object];
    self.currentSection = segment.selectedSegmentIndex;
    //NSLog(@"selectedSegmentIndex %i",segment.selectedSegmentIndex);
    [super performQuery];    
}


- (void) viewDidAppear:(BOOL)animated{
    [super performQuery];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(FeedCell *)sender
{
    CameraViewController *controller = segue.destinationViewController;
    if(self.currentSection == 1){
        controller.photo = sender.photo;
        controller.object = sender.object;
    }
}


#pragma mark - collection view stuff

- (void) objectsDidLoad:(NSError *)error{
    
    [super objectsDidLoad:error];
    if(error){
        NSLog(@"error: %@",error);
    }
    if (![PFUser currentUser]) return;    
    
    lastRefresh = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:lastRefresh forKey:FeedViewControllerLastRefreshKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PFQuery *)queryForCollection{
    
    if (![PFUser currentUser]) {
        PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
        //[query whereKey:kPAPPhotoUserKey equalTo:[PFUser currentUser]];
        [query setLimit:0];
        return query;
    }
    
    PFQuery *queryPhoto = [PFQuery queryWithClassName:@"Photo"];
    [queryPhoto includeKey:@"user"];
    [queryPhoto includeKey:@"user_full"];
    
    if(self.currentSection == 0){
        [queryPhoto whereKey:@"user" equalTo:[PFUser currentUser]];
    }
    
    if(self.currentSection == 1){
        [queryPhoto whereKey:@"state" equalTo:@"half"];
        [queryPhoto whereKey:@"user" notEqualTo:[PFUser currentUser]];
    }
    
    if(self.currentSection == 2){
        [queryPhoto whereKey:@"state" equalTo:@"full"];
    }
    
    
    
    
    
    [queryPhoto orderByDescending:@"updatedAt"];
    //[queryPhoto setLimit:4];
    [queryPhoto setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        queryPhoto.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    
    // If there is no network connection, we will hit the cache first.
    if (self.objects.count == 0 || ![[UIApplication sharedApplication].delegate performSelector:@selector(isParseReachable)]) {
        //NSLog(@"Loading from cache");
        [queryPhoto setCachePolicy:kPFCachePolicyCacheThenNetwork];
    }
    
    
    return queryPhoto;
}

# pragma mark - Collection View data source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //[super collectionView:collectionView numberOfItemsInSection:section];    
   return self.objects.count;
   
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{    
    
    FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.object = object;
    return cell;
}

#pragma mark - UICollectionViewDelegate


/*
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //{top, left, bottom, right}
    return UIEdgeInsetsMake(75, 10, 30, 10);
}
*/


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectItemAtIndexPath %@", [self objectAtIndexPath:indexPath]);
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor blueColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = nil;
}


@end
