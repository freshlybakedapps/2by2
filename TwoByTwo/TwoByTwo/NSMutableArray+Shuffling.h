//
//  NSMutableArray+Shuffling.h
//  TwoByTwo
//
//  Created by John Tubert on 1/2/15.
//  Copyright (c) 2015 John Tubert. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#include <Cocoa/Cocoa.h>
#endif

// This category enhances NSMutableArray by providing
// methods to randomly shuffle the elements.
@interface NSMutableArray (Shuffling)
- (void)shuffle;
@end

