//
//  MainViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "CameraViewController.h"
#import "UIImage+Addon.h"
#import "UICollectionView+Addon.h"
#import "UICollectionView+Pagination.h"
#import "AppDelegate.h"
#import "Constants.h"
#import "PopularContainerCell.h"
#import "PublicContainerCell.h"
#import "FriendsContainerCell.h"
#import "ProfileContainerCell.h"
#import "NotificationsContainerCell.h"


@interface MainViewController ()
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) IBOutlet UIPageControl *pageControl;
@end


@implementation MainViewController

+ (instancetype)currentController
{
    id controller = [AppDelegate delegate].window.rootViewController;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        controller = [[controller viewControllers] firstObject];
    }

    if ([controller isKindOfClass:self]) {
        return controller;
    }
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];

    [self.collectionView registerCellClass:[PopularContainerCell class]];
    [self.collectionView registerCellClass:[PublicContainerCell class]];
    [self.collectionView registerCellClass:[FriendsContainerCell class]];
    [self.collectionView registerCellClass:[ProfileContainerCell class]];
    [self.collectionView registerCellClass:[NotificationsContainerCell class]];
    self.collectionView.scrollsToTop = NO;
    
    self.pageControl.numberOfPages = ContentTypeCount;
    
    /*
    if ([PFUser currentUser]) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"app started" properties:@{
                                                @"username": [PFUser user].username,
                                                @"user": [PFUser user].objectId
                                                }];
    }
    */
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return ContentTypeCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ContentType type = indexPath.row;
    ContainerCell *cell;
    
    switch (type) {
            
        case ContentTypePopular:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PopularContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            break;
        }

        case ContentTypePublic:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([PublicContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            break;
        }
            
        case ContentTypeFriends:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FriendsContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            break;
        }
        
        case ContentTypeProfile:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ProfileContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            break;
        }

        case ContentTypeNotifications:
        default:
        {
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([NotificationsContainerCell class]) forIndexPath:indexPath];
            [cell performQuery];
            break;
        }
    }
    
    return cell;
}


#pragma mark - IBAction

- (IBAction)cameraButtonTapped:(id)sender
{
    CameraViewController *controller = [CameraViewController controller];
    [self presentViewController:controller animated:YES completion:nil];
    
}


#pragma mark - Notification

- (void)updateNotificationCount:(NSNotification *)notification
{
    NSNumber *count = notification.userInfo[NoficationUserInfoKeyCount];
    if (count.integerValue) {
        UIImage *image = [UIImage circleWithNumber:count.integerValue radius:30];
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(notificationButtonTapped:)];
        [self.navigationItem setRightBarButtonItem:item animated:YES];
    }
    else {
        [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

- (void)notificationButtonTapped:(id)sender
{
    [self showNotificationsAnimated:YES];
}

- (void)showNotificationsAnimated:(BOOL)animated
{
    [self.collectionView scrollToPage:ContentTypeNotifications];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger currentPage = self.collectionView.currentPage;
    if (self.pageControl.currentPage != currentPage) {
        self.pageControl.currentPage = currentPage;
        NSArray *cells = [self.collectionView visibleCells];
        [cells bk_each:^(ContainerCell *cell) {
            NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
            cell.collectionView.scrollsToTop = (indexPath.row == currentPage) ? YES : NO;
        }];
    }
}

@end