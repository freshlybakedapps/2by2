//
//  FeedViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedCell.h"
#import "DataManager.h"
#import "Photo.h"
#import "CameraViewController.h"


@interface FeedViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end


@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch:&error];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(FeedCell *)sender
{
    CameraViewController *controller = segue.destinationViewController;
    controller.photo = sender.photo;
}


#pragma mark - Collection View

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        NSFetchRequest *request =[NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:[DataManager sharedInstance].mainContext sectionNameKeyPath:nil cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
    cell.photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return cell;
}

@end
