//
//  NotificationHeader.m
//  TwoByTwo
//
//  Created by John Tubert on 1/22/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NotificationHeader.h"

@interface NotificationHeader ()
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@end




@implementation NotificationHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel.font = [UIFont appMediumFontOfSize:14];
    }
    return self;
}

- (IBAction)closeButtonTapped:(id)sender{
    [self.controller changeHeaderHeight];

 
    
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    self.titleLabel.font = [UIFont appMediumFontOfSize:14];
}


@end
