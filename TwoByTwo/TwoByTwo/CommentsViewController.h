//
//  CommentsViewController.h
//  TwoByTwo
//
//  Created by John Tubert on 12/18/13.
//  Copyright (c) 2013 Joseph Lin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSMutableArray *objects;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITableView *tableView;



@end