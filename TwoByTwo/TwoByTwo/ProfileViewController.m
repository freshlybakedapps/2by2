//
//  MainViewController.m
//  TwoByTwo
//
//  Created by John Tubert
//  Copyright (c) 2014 John Tubert. All rights reserved.
//

#import "ProfileViewController.h"
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


@interface ProfileViewController ()
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end


@implementation ProfileViewController

+ (instancetype)controller
{
    id controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    return controller;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];
    
    [self.collectionView registerCellClass:[ProfileContainerCell class]];
    
    self.collectionView.scrollsToTop = NO;
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ProfileContainerCell class]) forIndexPath:indexPath];
    
    cell.user = self.user;
    [cell performQuery];
    
    
    return cell;
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

@end