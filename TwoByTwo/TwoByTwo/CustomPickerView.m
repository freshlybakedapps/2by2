//
//  CustomPickerView.m
//  TwoByTwo
//
//  Created by Joseph Lin on 2/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "CustomPickerView.h"
#import "ImageCell.h"

static CGFloat const kItemSize = 32.0;
static CGFloat const kItemSpacing = 10.0;


@interface CustomPickerView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *frontCollectionView;
@property (nonatomic, strong) UICollectionView *rearCollectionView;
@property (nonatomic, strong) UIView *frontContainerView;
@property (nonatomic, strong) UIView *rearContainerView;
@property (nonatomic, strong) UIImageView *ringImageView;
@end


@implementation CustomPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self initialize];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    [self initialize];
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(kItemSize, kItemSize);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumLineSpacing = kItemSpacing;

    self.frontCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.frontCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.frontCollectionView.backgroundColor = [UIColor clearColor];
    self.frontCollectionView.showsVerticalScrollIndicator = NO;
    self.frontCollectionView.dataSource = self;
    self.frontCollectionView.delegate = self;
    [self.frontCollectionView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
    
    self.frontContainerView = [[UIView alloc] initWithFrame:self.bounds];
    self.frontContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.frontContainerView.backgroundColor = [UIColor clearColor];
    [self.frontContainerView addSubview:self.frontCollectionView];
    [self addSubview:self.frontContainerView];
    
    
    self.rearCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.rearCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rearCollectionView.backgroundColor = [UIColor clearColor];
    self.rearCollectionView.showsVerticalScrollIndicator = NO;
    self.rearCollectionView.dataSource = self;
    self.rearCollectionView.delegate = self;
    self.rearCollectionView.userInteractionEnabled = NO;
    [self.rearCollectionView registerNib:[UINib nibWithNibName:@"ImageCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCell"];
    
    self.rearContainerView = [[UIView alloc] initWithFrame:self.bounds];
    self.rearContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.rearContainerView.backgroundColor = [UIColor clearColor];
    [self.rearContainerView addSubview:self.rearCollectionView];
    [self insertSubview:self.rearContainerView belowSubview:self.frontContainerView];
    
    
    self.frontCollectionView.contentInset = self.rearCollectionView.contentInset = UIEdgeInsetsMake(0, 144, 0, 144);
    
    UIImage *ringImage = [UIImage imageNamed:@"icon-dot-ring"];
    self.ringImageView = [[UIImageView alloc] initWithImage:ringImage];
    self.ringImageView.center = self.frontContainerView.center;
    [self addSubview:self.ringImageView];
}

- (NSUInteger)currentItem
{
    NSInteger currentItem = roundf((self.frontCollectionView.contentOffset.x + self.frontCollectionView.contentInset.left) / (kItemSize + kItemSpacing));
    currentItem = MIN(MAX(0, currentItem), self.dataSource.count - 1);
    return currentItem;
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Mask top and bottom table views.
//    CGRect rect = CGRectInset(self.bounds, 0.5 * (CGRectGetWidth(self.frame) - kItemSize), 0);
    
    UIImage *dotImage = [UIImage imageNamed:@"icon-dot-on"];
    CALayer *topMask = [CALayer layer];
    topMask.frame = CGRectMake((self.bounds.size.width - dotImage.size.width) / 2, (self.bounds.size.height - dotImage.size.height) / 2, dotImage.size.width, dotImage.size.height);
    topMask.contents = (id)dotImage.CGImage;
//    topMask.backgroundColor = [UIColor blackColor].CGColor;
    self.frontContainerView.layer.mask = topMask;
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSString *imageName = (collectionView == self.rearCollectionView) ? @"icon-dot-off" : @"icon-dot-on";
    cell.imageView.image = [UIImage imageNamed:imageName];
    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    
//    [self.frontCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
//    
//    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
//        [self.delegate pickerView:self didSelectItem:indexPath.item];
//    }
//}


#pragma mark - Scroll view

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.frontCollectionView) {
        self.rearCollectionView.contentOffset = self.frontCollectionView.contentOffset;
    }
    
    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
        if (self.dataSource.count) {
            [self.delegate pickerView:self didSelectItem:self.currentItem];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat pageWidth = kItemSize + kItemSpacing;
    NSInteger numberOfPages = self.dataSource.count;
    CGFloat proposedOffset = targetContentOffset->x;
    NSInteger proposedPage = roundf((proposedOffset + scrollView.contentInset.left) / pageWidth);
    NSInteger currentPage = roundf((scrollView.contentOffset.x + scrollView.contentInset.left) / pageWidth);
    
    // what follows is a fix for a weird case where the scroll 'jumps' into place with no animation
    if (currentPage == proposedPage) {
        if ((currentPage == 0 && velocity.x > 0) ||
            (currentPage == (numberOfPages - 1) && velocity.x < 0) ||
            (currentPage > 0 && currentPage < (numberOfPages - 1) && fabs(velocity.x) > 0)) {
            
            // this forces the scrolling animation to stop in its current place
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [scrollView setContentOffset:CGPointMake((currentPage * pageWidth) - scrollView.contentInset.left, 0)];
                             }
                             completion:NULL];
        }
    }
    targetContentOffset->x = (pageWidth * proposedPage) - scrollView.contentInset.left;

    
//    if ([self.delegate respondsToSelector:@selector(pickerView:didSelectItem:)]) {
//        if (self.dataSource.count) {
//            [self.delegate pickerView:self didSelectItem:proposedPage];
//        }
//    }
}

@end
