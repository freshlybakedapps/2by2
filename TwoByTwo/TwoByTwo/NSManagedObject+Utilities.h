//
//  NSManagedObject+Utilities.h
//  Spread
//
//  Created by Joseph Lin on 8/6/12.
//  Copyright (c) 2012 R/GA. All rights reserved.
//

#import <CoreData/CoreData.h>

extern id objectOrNil(id object);


@interface NSManagedObject (Utilities)

+ (instancetype)insertObjectInContext:(NSManagedObjectContext*)context;
+ (NSManagedObject *)objectWithID:(NSString*)requestedID inContext:(NSManagedObjectContext*)context;
+ (NSManagedObject *)objectWithDict:(NSDictionary*)dict inContext:(NSManagedObjectContext*)context;
+ (void)objectsWithArray:(NSArray*)array inContext:(NSManagedObjectContext*)context completion:(void(^)(NSArray* objects))completion;

+ (NSArray *)objectsWithPredicate:(NSPredicate*)predicate sortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (NSUInteger)objectsCountWithPredicate:(NSPredicate*)predicate sortDescriptors:(NSArray*)sortDescriptors inContext:(NSManagedObjectContext*)context;
+ (NSArray *)allObjectsInContext:(NSManagedObjectContext*)context;
+ (NSUInteger)allObjectsCountInContext:(NSManagedObjectContext*)context;

@end
