//
//  VideoTableViewController.h
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

extern NSString *const UserDidLogoutNotification;

@interface VideoTableViewController : UITableViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end