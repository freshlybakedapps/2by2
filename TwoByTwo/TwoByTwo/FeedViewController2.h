//
//  ProfileViewController.h
//  MotorMouth
//
//  Created by John Tubert on 3/4/13.
//  Copyright (c) 2013 John Tubert. All rights reserved.
//


#import "CPFQueryCollectionViewController.h"

@interface FeedViewController2 : CPFQueryCollectionViewController <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) NSDate *lastRefresh;
@end
