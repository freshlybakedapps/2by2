//
//  UICollectionView+Pagination.h
//  Wink
//
//  Created by Joseph Lin on 4/25/14.
//  Copyright (c) 2014 Quirky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A category that enables paging with custom page width (i.e. when page width != view width).
 */
@interface UICollectionView (Pagination)

@property (nonatomic, readonly) BOOL isHorizontal;
@property (nonatomic, readonly) NSInteger currentPage;

- (void)scrollToPage:(NSInteger)page;
- (void)scrollToFirstPage;
- (void)scrollToLastPage;

/**
 *  Calculate the page to snap to using both velocity and targetContentOffset.
 *  If the page size is smaller than the view size, user might be able to swipe more than one page at a time. 
 *  If that's not the desired behavior, use `snapToPageAroundPage:velocity:targetContentOffset:` instead.
 *
 *  @param velocity            The velocity of the scroll view (in points) at the moment the touch was released.
 *  @param targetContentOffset The expected offset when the scrolling action decelerates to a stop.
 */
- (void)snapToPageWithVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

/**
 *  This method only allow user to scroll forward or backward one page at a time. Only velocity is used to determine the scroll direction.
 *
 *  @param pageWhenBeginDragging You sould get this number from scrollViewWillBeginDragging: and store it locally.
 *  @param velocity              The velocity of the scroll view (in points) at the moment the touch was released.
 *  @param targetContentOffset   The expected offset when the scrolling action decelerates to a stop.
 */
- (void)snapToPageAroundPage:(NSInteger)pageWhenBeginDragging velocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;

@end
