//
//  GridViewController.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "MainViewController.h"


@interface GridViewController : UICollectionViewController

@property (nonatomic) FeedType type;
@property (nonatomic, strong) NSArray *objects;
@property (nonatomic, strong) NSMutableArray *followers;

@property (nonatomic, strong) NSString *facebookId;

@end
