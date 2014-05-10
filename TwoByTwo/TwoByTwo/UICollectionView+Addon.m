//
//  UICollectionView+Addon.m
//  TwoByTwo
//
//  Created by Joseph Lin on 5/10/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "UICollectionView+Addon.h"


@implementation UICollectionView (Addon)

- (void)registerNibWithCellClass:(Class)cellClass
{
    NSString *className = NSStringFromClass(cellClass);
    UINib *nib = [UINib nibWithNibName:className bundle:nil];
    [self registerNib:nib forCellWithReuseIdentifier:className];
}

- (void)registerNibWithViewClass:(Class)viewClass forSupplementaryViewOfKind:(NSString *)kind
{
    NSString *className = NSStringFromClass(viewClass);
    UINib *nib = [UINib nibWithNibName:className bundle:nil];
    [self registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:className];
}

@end
