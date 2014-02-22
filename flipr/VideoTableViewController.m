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

NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface VideoTableViewController ()

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


@end
