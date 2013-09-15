//
//  DataManager.h
//  TwoByTwo
//
//  Created by Joseph Lin on 9/15/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+Utilities.h"


@interface DataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *mainContext;

+ (instancetype)sharedInstance;
+ (NSURL *)documentsDirectory;
- (NSFetchRequest *)fetchRequestWithName:(NSString *)name;
- (BOOL)save;

@end
