//
//  NotificationSettingCell.m
//  TwoByTwo
//
//  Created by Joseph Lin on 1/1/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

#import "NotificationSettingCell.h"


@implementation NotificationSettingCell

- (void)setKey:(NSString *)key
{
    _key = key;
    
    if (!self.cellSwitch) {
        self.cellSwitch = [UISwitch new];
        //self.cellSwitch.onTintColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1.0];
        
        
        [self.cellSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.accessoryView = self.cellSwitch;
    }
    
    NSNumber *value = [PFUser currentUser][key];
    self.cellSwitch.on = [value boolValue];
}

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    [[PFUser currentUser] setObject:@(sender.on) forKey:self.key];

    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            NSLog(@"error: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
        else {
            NSLog(@"succeeded saving preferences");
        }
    }];
}

@end
