//
//  SelectPhotosViewController.m
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "SelectPhotosViewController.h"

@interface SelectPhotosViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoSourceSegmentControl;
- (IBAction)photoSourceValueChanged:(id)sender;
- (void) onSignIn;
- (void)onError;
- (void) getUserPhotos;


@end

@implementation SelectPhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photoSourceValueChanged:(id)sender {
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        NSLog(@"Selected Camera roll");
    }else{
        NSLog(@"Selected Flickr");
        if([FlickrUser currentFlickrUser]){
            [self onSignIn];
            
        }else{
            
            [self onSignIn];
        }
    }
    
}
-(void) onSignIn{
    NSLog(@"In onSignIn ");
    [[FlickrClient instance] authorizeWithCallbackUrl:[NSURL URLWithString:@"cp-flipr://success"] success:^(AFOAuth1Token *accessToken, id responseObject) {
        
        [[FlickrClient instance] currentUserWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
            id responseobject = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
            NSLog(@"Flickr User object: %@", responseobject);
            [FlickrUser setCurrentFlickrUser:[[FlickrUser alloc] initWithDictionary:responseobject]];
            [self getUserPhotos];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self onError];
        }];
        } failure:^(NSError *error) {
    
        [self onError];
    }];
    
}

- (void)onError {
    [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Couldn't log in with Twitter, please try again!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

- (void) getUserPhotos{
    [[FlickrClient instance] getFlickrPhotosWithCount:20  success:^(AFHTTPRequestOperation *operation, id response) {

        id object = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        NSLog(@"User pics: %@", object);
        // self.tweets = [Tweet tweetsWithArray:object];
        //[self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];

    
}
@end
