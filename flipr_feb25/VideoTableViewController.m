//
//  VideoTableViewController.m
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>

NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface VideoTableViewController ()
- (void) deleteVideo:(NSIndexPath *)indexPath;

@end

@implementation VideoTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // This table displays items in the Todo class
        self.parseClassName = @"UserVideo";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = NO;
        self.objectsPerPage = 25;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadObjects];
    NSLog(@"In VideoTableViewController ViewDidLoad");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStylePlain target:self action:@selector(onSignOutButton)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddNewButton)];
    
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache
    // first to fill the table and then subsequently do a query
    // against the network.
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    static NSString *CellIdentifier = @"VideoCell";
    
    VideoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    // Configure the cell to show todo item with a priority at the bottom
    cell.titleLabel.text = [object objectForKey:@"title"];
    cell.durationLabel.text = [object objectForKey:@"duration"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, MMM d, ''yy"];
    cell.createDateLabel.text = [NSString stringWithFormat:@"Created at: %@", [dateFormatter stringFromDate:object.createdAt]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    
    PFObject *selectedObject = [self objectAtIndexPath:indexPath];
    NSURL *theURL = [NSURL URLWithString:selectedObject[@"videoUrl"]];
    
    MPMoviePlayerViewController *movieVC = [[MPMoviePlayerViewController alloc] initWithContentURL:theURL];
    [self presentMoviePlayerViewControllerAnimated:movieVC];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Reove the video from S3 and Parse
        [self deleteVideo:indexPath];
        
    }
}

#pragma mark - Private methods

- (void)onSignOutButton {
    NSLog(@"Signing out...");
    [PFUser logOut];
    
    // Send the log out notification to go back to log in screen
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];

}

#pragma - Segue methods
/*
- (void)onAddNewButton {
    
    [self performSegueWithIdentifier:@"createVCSegue" sender:self];
    
}
 */

- (void) deleteVideo:(NSIndexPath *)indexPath {
    
    PFObject *selectedObject = [self objectAtIndexPath:indexPath];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // handle the case where there is no key (just remove the parse record)
        if (selectedObject[@"S3uniqueKey"] != nil) {
            
            AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJJH522J3C3GOD2VA"
                                                             withSecretKey:@"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"];
            s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
            
            S3DeleteObjectResponse *response = [s3 deleteObjectWithKey:selectedObject[@"S3uniqueKey"]
                                                            withBucket:@"group13videos-akiajjh522j3c3god2va"];
            
            if ([response error]) {
                return;
            }
        }
        
        // Remove the object from Parse
        [selectedObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self loadObjects];
                //[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                //                 withRowAnimation:UITableViewRowAnimationFade];
            });
            
        }];
        
    });
}


@end
