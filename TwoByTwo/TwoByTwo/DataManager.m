//
//  DataManager.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/15/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "DataManager.h"


@interface DataManager ()
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *mainContext;
@end


@implementation DataManager

- (BOOL)save
{
    NSError *error = nil;
    BOOL success = [self.mainContext save:&error];
    if (error) {
        NSLog(@"error saving context: %@", error);
    }
    return success;
}

- (NSFetchRequest *)fetchRequestWithName:(NSString *)name
{
    NSFetchRequest *fetchRequest = [self.managedObjectModel fetchRequestTemplateForName:name];
    return fetchRequest;
}

#pragma mark -

+ (instancetype)sharedInstance
{
    static DataManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [DataManager new];
    });
    return _sharedInstance;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"TwoByTwo" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator)
    {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        
        NSURL *storeURL = [[DataManager documentsDirectory] URLByAppendingPathComponent:@"TwoByTwo.sqlite"];
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES};
        NSError *error = nil;
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
        {
            NSLog(@"Failed to add persistent store: %@", error);
            
            NSLog(@"Will remove current database and try again...");
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
            
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
            {
                NSLog(@"Unresolved error: %@", error);
            }
        }
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)mainContext
{
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    return _mainContext;
}



#pragma mark - Application's Documents directory

+ (NSURL *)documentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
