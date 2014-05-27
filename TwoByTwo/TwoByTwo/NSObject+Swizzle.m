//
//  NSObject+Swizzle.m
//  TwoByTwo
//
//  Created by Joseph Lin on 8/19/13.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NSObject+Swizzle.h"


@implementation NSObject (Swizzle)

+ (void)swizzleSelector:(SEL)originalSelector withSelector:(SEL)otherSelector
{
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
	Method otherMethod = class_getInstanceMethod(self, otherSelector);
    
	class_addMethod(self, originalSelector, class_getMethodImplementation(self, originalSelector), method_getTypeEncoding(originalMethod));
	class_addMethod(self, otherSelector, class_getMethodImplementation(self, otherSelector), method_getTypeEncoding(otherMethod));
    
	method_exchangeImplementations(originalMethod, otherMethod);
}

+ (void)swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)otherSelector
{
    Method originalMethod = class_getClassMethod(self, originalSelector);
	Method otherMethod = class_getClassMethod(self, otherSelector);
    
	class_addMethod(self, originalSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
	class_addMethod(self, otherSelector, method_getImplementation(otherMethod), method_getTypeEncoding(otherMethod));
    
	method_exchangeImplementations(originalMethod, otherMethod);
}


@end
