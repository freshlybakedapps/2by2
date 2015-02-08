//
//  FriendsViewController.m
//  TwoByTwo
//
//  Created by Tuberts on 2/8/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#import "FriendsViewController.h"

#import "CameraViewController.h"
#import "UIImage+Addon.h"
#import "UICollectionView+Addon.h"
#import "UICollectionView+Pagination.h"
#import "AppDelegate.h"
#import "CameraFriendsContainerCell.h"



@interface FriendsViewController ()
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end


@implementation FriendsViewController


+ (instancetype)controller
{
    id controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FriendsViewController"];
    return controller;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationCount:) name:NoficationDidUpdatePushNotificationCount object:nil];
    
    [self.collectionView registerCellClass:[CameraFriendsContainerCell class]];
    
    
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CameraFriendsContainerCell"];
    
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
    CameraFriendsContainerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([CameraFriendsContainerCell class]) forIndexPath:indexPath];
    
    cell.cameraViewController = self.cameraViewController;
    
    cell.parent = self;
    
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