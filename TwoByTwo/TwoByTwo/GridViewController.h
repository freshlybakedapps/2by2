//
//  GridViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"
#import "GridViewController.h"


@interface GridViewController : UICollectionViewController

@property (nonatomic) FeedType type;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableArray *followers;
@property (nonatomic, strong) PFUser *friend;
@property (nonatomic, strong) NSNumber *limit;

@property (nonatomic, strong) NSString *photoID;

@property (nonatomic, strong) NSString *facebookId;

@property (nonatomic, strong) NSNumber* totalObjects;


@end
