//
//  GridHeaderView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 11/17/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridViewController.h"


@interface GridHeaderView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *usernameLabel;
@property (nonatomic, weak) IBOutlet UILabel *emailLabel;
@property (nonatomic, weak) IBOutlet UILabel *numPhotosLabel;
@property (nonatomic, weak) IBOutlet UILabel *followingLabel;
@property (nonatomic, weak) IBOutlet UILabel *followersLabel;
@property (nonatomic, weak) IBOutlet UITextView *bioTextview;
@property (nonatomic, weak) IBOutlet UIImageView *photo;

@property (nonatomic, weak) GridViewController* controller;


- (IBAction)showEverythingElse:(id)sender;

- (void)render;

@end
