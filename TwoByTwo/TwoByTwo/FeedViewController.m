//
//  FeedViewController.m
//  TwoByTwo
//
//  Created by Joseph Lin on 9/10/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "FeedViewController.h"
#import "CameraViewController.h"
#import "PDPViewController.h"
#import "FeedCell.h"
#import "ThumbCell.h"
#import "FeedHeaderView.h"
#import "FeedProfileHeaderView.h"
#import "FeedFooterView.h"
#import "AppDelegate.h"


static NSUInteger const kQueryBatchSize = 20;


@interface FeedViewController () <FeedCellDelegate, FeedHeaderViewDelegate>
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) NSMutableArray *hashPhotoIds;
@property (nonatomic, strong) NSArray *followers;
@property (nonatomic) NSUInteger totalNumberOfObjects;
@property (nonatomic) NSUInteger queryOffset;
@property (nonatomic) BOOL showingFeed;
@property (nonatomic) BOOL showingDouble;

@property (nonatomic, strong) FeedFooterView* footerView;
@end


@implementation FeedViewController

+ (instancetype)controller
{
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FeedViewController"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performQuery) name:NoficationShouldReloadPhotos object:nil];

    if (self.user) {
        [self.user fetchInBackgroundWithBlock:^(PFObject *object, NSError *error){
            self.title = [object.fullName uppercaseString];
        }];
    }
    
    self.showingDouble = YES;
    
    if (self.hashtag) {
        self.title = @"Hashtag";//self.hashtag;
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedProfileHeaderView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedProfileHeaderView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedFooterView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FeedFooterView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FeedCell" bundle:nil] forCellWithReuseIdentifier:@"FeedCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"ThumbCell" bundle:nil] forCellWithReuseIdentifier:@"ThumbCell"];
    
    
    // Load Data    
    AppDelegate* delegate = [AppDelegate delegate];
    if(delegate.pdpID){
        PDPViewController *controller = [PDPViewController controller];
        controller.photoID = delegate.pdpID;
        [self.navigationController pushViewController:controller animated:YES];
        delegate.pdpID = nil;
    }else{
        [self performQuery];
    }
    
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    /*
     Source:
     http://stackoverflow.com/questions/19038949/content-falls-beneath-navigation-bar-when-embedded-in-custom-container-view-cont
     */
    
    if ([parent isKindOfClass:[MainViewController class]] && self.navigationController.topViewController == parent) {
        CGFloat top = parent.topLayoutGuide.length;
        CGFloat bottom = parent.bottomLayoutGuide.length;
        if (self.collectionView.contentInset.top != top) {
            UIEdgeInsets newInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
            self.collectionView.contentInset = newInsets;
            self.collectionView.scrollIndicatorInsets = newInsets;
        }
    }
    else {
        [super didMoveToParentViewController:parent];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




#pragma mark - Query


- (void)performQuery
{
    
    NSLog(@"performQuery");
    
    if (self.type == FeedTypeFollowing || self.type == FeedTypeGlobal) {
        [self loadFollowers];
    }
    else if(self.type == FeedTypeHashtag){
        [self loadComments];
    }else{
        [self loadPhotos];
    }
}


- (void)loadComments
{
    self.hashPhotoIds = [NSMutableArray new];
    
    PFQuery *query = [PFQuery queryWithClassName:PFCommentClass];
    [query whereKey:@"text" containsString:self.hashtag];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (int i=0; i<objects.count; i++) {
                PFObject* comment = [objects objectAtIndex:i];
                [self.hashPhotoIds addObject:[comment objectForKey:@"commentID"]];
            }
            [self loadPhotos];
        }
        else {
            NSLog(@"loadFollowers error: %@", error);
        }
    }];
}


- (void)loadFollowers
{
    PFQuery *query = [PFQuery queryWithClassName:PFFollowersClass];
    if ([PFUser currentUser]) {
        [query whereKey:PFUserIDKey equalTo:[PFUser currentUser].objectId];
    }
    [query selectKeys:@[PFFollowingUserIDKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.followers = [objects bk_map:^id(id object) {
                NSString *userID = object[PFFollowingUserIDKey];
                PFUser *user = [PFUser objectWithoutDataWithObjectId:userID];
                return user;
            }];
            [self loadPhotos];
        }
        else {
            NSLog(@"loadFollowers error: %@", error);
        }
    }];
}

- (void)loadPhotos
{
    PFQuery *query = nil;
    
    switch (self.type) {
        case FeedTypeSingle:
            query = [PFQuery queryWithClassName:PFPhotoClass];
            [query whereKey:PFStateKey equalTo:PFStateValueHalf];
            [query whereKey:PFUserKey notEqualTo:[PFUser currentUser]];
            break;
            
        case FeedTypeGlobal:
            query = [PFQuery queryWithClassName:PFPhotoClass];
            [query whereKey:PFStateKey equalTo:PFStateValueFull];
            [query whereKey:PFUserKey notContainedIn:self.followers];
            [query whereKey:PFUserFullKey notContainedIn:self.followers];
            break;
            
        case FeedTypeFollowing: {
            PFQuery *userQuery = [PFQuery queryWithClassName:PFPhotoClass];
            [userQuery whereKey:PFUserKey containedIn:self.followers];
            
            PFQuery *userFullQuery = [PFQuery queryWithClassName:PFPhotoClass];
            [userFullQuery whereKey:PFUserFullKey containedIn:self.followers];
            
            query = [PFQuery orQueryWithSubqueries:@[userQuery, userFullQuery]];
            [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
            
            break;
        }
            
        case FeedTypeYou: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", [PFUser currentUser], [PFUser currentUser]];
            query = [PFQuery queryWithClassName:PFPhotoClass predicate:predicate];
            [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
            break;
        }
            
        case FeedTypeFriend: {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"user == %@ OR user_full == %@", self.user, self.user];
            query = [PFQuery queryWithClassName:PFPhotoClass predicate:predicate];
            [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
            break;
        }
            
        case FeedTypeHashtag: {
            query = [PFQuery queryWithClassName:PFPhotoClass];
            NSLog(@"hashPhotoIds: %@",self.hashPhotoIds);
            [query whereKey:@"objectId" containedIn:self.hashPhotoIds];
            [query whereKey:PFStateKey equalTo:(self.showingDouble) ? PFStateValueFull : PFStateValueHalf];
            break;
        }
            
        default:
            break;
    }
    
    
    if (!query) {
        return;
    }
    
    
    [query includeKey:PFUserKey];
    [query includeKey:PFUserFullKey];
    [query orderByDescending:PFCreatedAtKey];
    
    [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        
        self.totalNumberOfObjects = number;
        query.limit= kQueryBatchSize;
        query.skip = self.objects.count;
        //[query orderByDescending:@"createdAt"];
        
        [query setCachePolicy:kPFCachePolicyNetworkElseCache];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            if (!error) {
                
                if (!self.objects) {
                    self.objects = [NSMutableArray array];
                }
                
                [self.collectionView performBatchUpdates:^{
                    NSUInteger count = self.objects.count;
                    NSMutableArray *indexPaths = [NSMutableArray array];
                    
                    for (NSUInteger i = count; i < count + objects.count; i++) {
                        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                    
                    [self.objects addObjectsFromArray:objects];
                    [self.collectionView insertItemsAtIndexPaths:indexPaths];
                    
                    //[self.collectionView deleteItemsAtIndexPaths:indexPaths];
                    
                    
                   
                } completion:nil];
            }
            else {
                self.objects = nil;
                [self.collectionView reloadData];
                [[[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
            
            [self loadNotifications];
        }];
    }];
}

- (void)loadNotifications
{
    [[PFUser currentUser] fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        
        NSDate *date = object.notificationWasAccessed;
        
        PFQuery *query = [PFQuery queryWithClassName:PFNotificationClass];
        [query whereKey:PFNotificationIDKey equalTo:object.objectId];
        
        if(date){
            [query whereKey:PFCreatedAtKey greaterThan:date];
        }
        
        [query countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            if(!error){
                [[NSNotificationCenter defaultCenter] postNotificationName:NoficationDidUpdatePushNotificationCount object:self userInfo:@{NoficationUserInfoKeyCount:@(number)}];
            }
        }];
    }];
}


#pragma mark - Collection View

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10.0 : 2.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return (self.showingFeed) ? 10.0 : 2.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.showingFeed) ? CGSizeMake(320, 410) : CGSizeMake(78.5, 78.5);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.objects.count - 1 && self.objects.count < self.totalNumberOfObjects) {
        [self performQuery];
    }
    
    if (!self.showingFeed) {
        ThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbCell" forIndexPath:indexPath];
        cell.photo = self.objects[indexPath.row];        
        return cell;
    }
    else {
        FeedCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedCell" forIndexPath:indexPath];
        cell.shouldHaveDetailLink = YES;
        cell.photo = self.objects[indexPath.row];
        
        cell.delegate = self;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *photo = self.objects[indexPath.row];

    if (self.showingFeed && [photo.state isEqualToString:PFStateValueHalf] && ![photo.user.objectId isEqualToString:[PFUser currentUser].objectId]) {
        CameraViewController *controller = [CameraViewController controller];
        controller.photo = photo;
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        PDPViewController *controller = [PDPViewController controller];
        controller.photoID = photo.objectId;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark - Collection View Header

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    switch (self.type) {
        case FeedTypeFriend:
        case FeedTypeYou:
            return CGSizeMake(0, [FeedProfileHeaderView headerHeightForType:self.type]);
            
        default:
            return CGSizeMake(0, [FeedHeaderView headerHeightForType:self.type]);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if(self.totalNumberOfObjects == 0){
        self.footerView.hidden = NO;
    }else{
        self.footerView.hidden = YES;
    }
    
    
    return (self.totalNumberOfObjects == 0) ? CGSizeMake(0, 300) : CGSizeMake(0, 1); // Setting CGSizeZero causes crash
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        switch (self.type) {
            case FeedTypeFriend:
            case FeedTypeYou: {
                FeedProfileHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedProfileHeaderView" forIndexPath:indexPath];
                headerView.user = (self.type == FeedTypeFriend) ? self.user : nil;
                headerView.delegate = self;
                return headerView;
            }
                
            default: {
                FeedHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FeedHeaderView" forIndexPath:indexPath];
                
                
                if(self.type == FeedTypeHashtag && self.hashtag){
                    headerView.title = [NSString stringWithFormat:@"%@",self.hashtag];
                }
                
                headerView.type = self.type;
                headerView.delegate = self;
                
                return headerView;
            }
        }
    }
    else {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FeedFooterView" forIndexPath:indexPath];
        self.footerView.controller = self;
        self.footerView.showingDouble = self.showingDouble;
        self.footerView.type = self.type;
        self.footerView.hidden = YES;
        return self.footerView;
    }
    return nil;
}


#pragma mark - FeedCell Delegate

- (void)cell:(FeedCell *)cell showProfileForUser:(PFUser *)user
{
    FeedViewController *controller = [FeedViewController controller];
    controller.type = FeedTypeFriend;
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)cell:(FeedCell *)cell showCommentsForPhoto:(PFObject *)photo
{
    PDPViewController *controller = [PDPViewController controller];
    controller.photoID = photo.objectId;
    [self.navigationController pushViewController:controller animated:YES];
}


#pragma mark - FeedHeaderViewDelegate

- (void)setShowingFeed:(BOOL)showingFeed
{
    _showingFeed = showingFeed;
    [self.collectionView reloadData];
}

- (void)setShowingDouble:(BOOL)showingDouble
{
    _showingDouble = showingDouble;
    self.objects = nil;
    [self.collectionView reloadData];
    [self loadPhotos];
}

- (void)updateHeaderHeight
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    ABMultiValueRef fnameProperty = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    ABMultiValueRef lnameProperty = ABRecordCopyValue(person, kABPersonLastNameProperty);
    ABMultiValueRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    NSArray *emailArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(emailProperty));
    CFRelease(emailProperty);
    
    NSArray *phoneArray = CFBridgingRelease(ABMultiValueCopyArrayOfAllValues(phoneProperty));
    CFRelease(phoneProperty);
    
    NSString* name;
    NSString* email;
    NSString* phone;
    
    if (fnameProperty != nil) {
        name = [NSString stringWithFormat:@"%@", fnameProperty];
        CFRelease(fnameProperty);
    }
    if (lnameProperty != nil) {
        name = [name stringByAppendingString:[NSString stringWithFormat:@" %@", lnameProperty]];
        CFRelease(lnameProperty);
    }
    if ([emailArray count] > 0) {
        email = [NSString stringWithFormat:@"%@", emailArray[0]];
    }
    if ([phoneArray count] > 0) {
        phone = [NSString stringWithFormat:@"%@", phoneArray[0]];
    }
    
    NSString *msg = @"I am inviting you to check out my photos on 2by2. Download the app, it's totally free! https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8";
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (email && phone) {
            UIAlertView *alert = [UIAlertView bk_alertViewWithTitle:nil message:@"Send message by:"];
            [alert bk_addButtonWithTitle:@"BY EMAIL" handler:^{
                [self sendEmail:email];
            }];
            [alert bk_addButtonWithTitle:@"BY TEXT" handler:^{
                [self sendSMS:msg recipientList:@[phone]];
            }];
            [alert bk_setCancelButtonWithTitle:@"CANCEL" handler:^{
                //cancel
            }];
            [alert show];
        }
        else if(email) {
            [self sendEmail:email];
        }
        else if(phone) {
            [self sendSMS:msg recipientList:@[phone]];
        }
        else {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry that contact didn't contain any email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
    
    return NO;
}

- (void)sendEmail:(NSString *)email
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        [controller setSubject:@"Check out my photos on 2by2"];
        [controller setToRecipients:@[email]];
        [controller setMessageBody:@"I am inviting you to check out my photos on 2by2. <a href='https://itunes.apple.com/us/app/2by2!/id836711608?ls=1&mt=8'>Download the app, it's totally free!</a>" isHTML:YES];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    if([MFMessageComposeViewController canSendText]) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        controller.messageComposeDelegate = self;
        controller.recipients = recipients;
        controller.body = bodyOfMessage;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled) {
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent) {
        NSLog(@"Message sent");
        
    }
    else {
        NSLog(@"Message failed");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}



@end
