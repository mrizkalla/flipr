//
//  CreateVideoViewController.h
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AWSS3/AWSS3.h>
#import <MessageUI/MessageUI.h>

@interface CreateVideoViewController : UIViewController <AmazonServiceRequestDelegate>

@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@end
