//
//  ProgressButton.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/15/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProgressButton : UIButton
@property (nonatomic, strong) UIColor *outerColor;
@property (nonatomic, strong) UIColor *innerColor;
@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic) CGFloat trackInset;
@property (nonatomic) CGFloat trackWidth;
@end
