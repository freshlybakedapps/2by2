//
//  CustomPickerView.h
//  TwoByTwo
//
//  Created by Joseph Lin on 2/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomPickerViewDelegate;


@interface CustomPickerView : UIView

@property (nonatomic, weak) IBOutlet id <CustomPickerViewDelegate> delegate;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, readonly) NSUInteger currentItem;

@end


@protocol CustomPickerViewDelegate <NSObject>
@optional
- (void)pickerView:(CustomPickerView *)pickerView didSelectItem:(NSInteger)item;
@end
