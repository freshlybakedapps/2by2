//
//  UICollectionView+Addon.h
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UICollectionView (Addon)

- (void)registerNibWithCellClass:(Class)cellClass;
- (void)registerNibWithViewClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind;

@end
