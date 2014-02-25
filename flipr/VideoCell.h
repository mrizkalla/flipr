//
//  VideoCell.h
//  flipr
//
//  Created by Michael Rizkalla on 2/2/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface VideoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *createDateLabel;
@property (weak, nonatomic) IBOutlet PFImageView *coverPhoto;
@end
