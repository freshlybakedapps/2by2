//
//  CommentsViewController.m
//  TwoByTwo
//
//  Created by John Tubert on 12/18/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import "CommentsViewController.h"
#import "DAKeyboardControl.h"
#import "NSString+MD5.h"
#import "UIImageView+Network.h"
#import "UIImageView+CircleMask.h"
#import "CommentCell.h"


@interface CommentsViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UITextField *textField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, strong) NSMutableArray *objects;
@end


@implementation CommentsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    __weak typeof(self) weakSelf = self;    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        
        CGFloat height = CGRectGetHeight(weakSelf.view.window.frame);
        weakSelf.bottomConstraint.constant = height - keyboardFrameInView.origin.y;
        [weakSelf.view layoutIfNeeded];

        if (weakSelf.objects.count > 0){
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.objects.count - 1 inSection:0];
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
    
    [self performQuery];
}

- (void)dealloc
{
    [self.view removeKeyboardControl];
}


#pragma mark -

- (void)performQuery
{
    __weak typeof(self) weakSelf = self;

    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"commentID" equalTo:self.commentID];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        if (!error) {
            weakSelf.objects = [objects mutableCopy];
            [weakSelf.tableView reloadData];
            
            if (objects.count) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:objects.count - 1 inSection:0];
                [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }];
}


#pragma mark -

- (IBAction)closeButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendButtonTapped:(UIButton *)sender
{
    if (self.textField.text.length == 0) {
        return;
    }
 
    sender.enabled = NO;
    __weak typeof(self) weakSelf = self;

    PFObject *comment = [PFObject objectWithClassName:@"Comment"];
    comment[@"text"] = self.textField.text;
    comment[@"username"] = [PFUser currentUser].username;
    comment[@"commentID"] = self.commentID;
    comment[@"facebookId"] = [PFUser currentUser][@"facebookId"];
    comment[@"userID"] = [PFUser currentUser].objectId;
    
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

        if (!error) {
            [weakSelf.tableView beginUpdates];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.objects.count inSection:0];
            [weakSelf.objects addObject:comment];
            [weakSelf.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
            [weakSelf.tableView endUpdates];
            
            [weakSelf.tableView scrollToRowAtIndexPath:indexPath atScrollPosition: UITableViewScrollPositionTop animated: YES];
        }
        
        sender.enabled = YES;
        weakSelf.textField.text = nil;
    }];
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *comment = self.objects[indexPath.row];
    NSString *text = comment[@"text"];
    
    CGRect rect = [text boundingRectWithSize:CGSizeMake(260, MAXFLOAT)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont appFontOfSize:14]}
                                     context:nil];
    
    CGFloat cellHeight = 38 + rect.size.height + 10;
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.comment = self.objects[indexPath.row];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //only allow to edit my own comments
    PFObject *comment = self.objects[indexPath.row];
    if ([comment[@"username"] isEqualToString:[PFUser currentUser].username]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        __weak typeof(self) weakSelf = self;
        PFObject *comment = self.objects[indexPath.row];
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [weakSelf.tableView beginUpdates];
            [weakSelf.objects removeObject:comment];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [weakSelf.tableView endUpdates];
        }];
    }
}

@end
