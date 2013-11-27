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
@property (nonatomic, weak) IBOutlet UILabel *textLabel;
@property (nonatomic, weak) GridViewController* controller;

- (IBAction)showEverythingElse:(id)sender;



@end
