//
//  FeedViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "GridViewController.h"
#import "GridCell.h"
#import "CameraViewController.h"


@interface GridViewController ()
@property (nonatomic, strong) NSArray *objects;
@end


@implementation GridViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performQuery];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(GridCell *)sender
{
//    CameraViewController *controller = segue.destinationViewController;
//    controller.photo = sender.object;
}

- (void)performQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query includeKey:@"user"];
    [query includeKey:@"user_full"];
    
    switch (self.type) {
        case FeedTypeYou:
            [query whereKey:@"user" equalTo:[PFUser currentUser]];
            break;
            
        case FeedTypeSingle:
            [query whereKey:@"state" equalTo:@"half"];
            [query whereKey:@"user" notEqualTo:[PFUser currentUser]];
            break;
            
        case FeedTypeGlobal:
        default:
            [query whereKey:@"state" equalTo:@"full"];
            break;
    }
    
    [query orderByDescending:@"updatedAt"];
    [query setCachePolicy:kPFCachePolicyCacheThenNetwork];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {
            self.objects = objects;
        }
        else {
            self.objects = @[];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        
        [self.collectionView reloadData];
    }];
}


#pragma mark - Collection View

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridCell" forIndexPath:indexPath];
    PFObject *object = self.objects[indexPath.row];
    cell.object = object;
    return cell;
}

@end
