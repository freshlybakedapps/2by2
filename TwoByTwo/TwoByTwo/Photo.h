//
//  Photo.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/15/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * photoPath;
@property (nonatomic, retain) User *user;

@end
