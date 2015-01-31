//
//  UICollectionView+Pagination.m
//  Wink
//
//  Created by Joseph Lin on 4/25/14.
//  Copyright (c) 2014 Quirky. All rights reserved.
//

#import "UICollectionView+Pagination.h"


@implementation UICollectionView (Pagination)


#pragma mark - Calculations

- (NSInteger)pageFromOffset:(CGFloat)offset
{
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"CollectionView is not using UICollectionViewFlowLayout!");
    
    UICollectionViewFlowLayout *layout = (id)self.collectionViewLayout;
    UICollectionViewScrollDirection direction = layout.scrollDirection;
    BOOL isHorizontal = (direction == UICollectionViewScrollDirectionHorizontal);
    
    CGFloat spacing     = layout.minimumLineSpacing;
    CGFloat inset       = (isHorizontal) ? layout.sectionInset.left : layout.sectionInset.top;
    CGFloat itemSize    = (isHorizontal) ? layout.itemSize.width    : layout.itemSize.height;
    CGFloat viewSize    = (isHorizontal) ? self.frame.size.width    : self.frame.size.height;
    
    float page = (offset + viewSize/2 - itemSize/2 - inset ) / (itemSize + spacing);
    return roundf(page);
}

- (CGFloat)offsetForPage:(NSInteger)page
{
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"CollectionView is not using UICollectionViewFlowLayout!");
    
    UICollectionViewFlowLayout *layout = (id)self.collectionViewLayout;
    UICollectionViewScrollDirection direction = layout.scrollDirection;
    BOOL isHorizontal = (direction == UICollectionViewScrollDirectionHorizontal);
    
    CGFloat spacing     = layout.minimumLineSpacing;
    CGFloat inset       = (isHorizontal) ? layout.sectionInset.left : layout.sectionInset.top;
    CGFloat itemSize    = (isHorizontal) ? layout.itemSize.width    : layout.itemSize.height;
    CGFloat viewSize    = (isHorizontal) ? self.frame.size.width    : self.frame.size.height;
    
    CGFloat offset = page * (itemSize + spacing) - viewSize/2 + itemSize/2 + inset;
    return offset;
}


#pragma mark - Utilities

- (BOOL)isHorizontal
{
    NSAssert([self.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]], @"CollectionView is not using UICollectionViewFlowLayout!");
    
    UICollectionViewFlowLayout *layout = (id)self.collectionViewLayout;
    UICollectionViewScrollDirection direction = layout.scrollDirection;
    BOOL isHorizontal = (direction == UICollectionViewScrollDirectionHorizontal);
    return isHorizontal;
}

- (NSInteger)currentPage
{
    CGFloat offset = (self.isHorizontal) ? self.contentOffset.x : self.contentOffset.y;
    NSInteger page = [self pageFromOffset:offset];
    return roundf(page);
}

- (void)scrollToFirstPage
{
    NSInteger count = [self numberOfItemsInSection:0];
    if (count > 0) {
        [self scrollToPage:0];
    }
}

- (void)scrollToLastPage
{
    NSInteger count = [self numberOfItemsInSection:0];
    if (count > 0) {
        [self scrollToPage:count - 1];
    }
}

- (void)scrollToPage:(NSInteger)page
{
    CGFloat offset = [self offsetForPage:page];
    CGPoint point = (self.isHorizontal) ? CGPointMake(offset, 0) : CGPointMake(0, offset);
    [self setContentOffset:point animated:YES];
}

- (void)snapToPageWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    BOOL isHorizontal = self.isHorizontal;

    CGFloat targetOffset = (isHorizontal) ? targetContentOffset->x : targetContentOffset->y;
    NSInteger targetPage = [self pageFromOffset:targetOffset];
    
    CGFloat currentOffset = (isHorizontal) ? self.contentOffset.x : self.contentOffset.y;
    NSInteger currentPage = [self pageFromOffset:currentOffset];
    
    // To make sure targetContentOffset is always in the same direction as the velocity.
    // If it's in the opposite direction, the scrolling won't be animated and thus looks glitched.
    if (targetPage == currentPage) {
        if (velocity.x < 0)
            targetPage--;
        else if (velocity.x > 0)
            targetPage++;
    }

    CGFloat desiredOffset = [self offsetForPage:targetPage];
    if (isHorizontal) {
        targetContentOffset->x = MIN(MAX(desiredOffset, 0), self.contentSize.width - self.frame.size.width);

    }
    else {
        targetContentOffset->y = MIN(MAX(desiredOffset, 0), self.contentSize.height - self.frame.size.height);
    }
}

- (void)snapToPageAroundPage:(NSInteger)pageWhenBeginDragging velocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger targetPage = self.currentPage;
    if (velocity.x < 0)
        targetPage = pageWhenBeginDragging - 1;
    else if (velocity.x > 0)
        targetPage = pageWhenBeginDragging + 1;
    
    CGFloat desiredOffset = [self offsetForPage:targetPage];
    targetContentOffset->x = MIN(MAX(desiredOffset, 0), self.contentSize.width - self.frame.size.width);
}


@end
