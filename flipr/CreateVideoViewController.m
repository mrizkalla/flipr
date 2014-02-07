//
//  CreateVideoViewController.m
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "CreateVideoViewController.h"
#import <Parse/Parse.h>
#import <AWSS3/AWSS3.h>
#import <AWSRuntime/AWSRuntime.h>
#import "DejalActivityView.h"


@interface CreateVideoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *videoTitleTextField;
@property (nonatomic, strong) AmazonS3Client *s3;

- (IBAction)onDoneButton:(id)sender;
- (void)getVideoUrl;

@end

@implementation CreateVideoViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        self.s3 = [[AmazonS3Client alloc] initWithAccessKey:@"AKIAJJH522J3C3GOD2VA"
                                                         withSecretKey:@"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"];
        self.s3.endpoint = [AmazonEndpoints s3Endpoint:US_WEST_2];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"selectedPhotos to create video: %@", self.selectedPhotos);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onDoneButton:(id)sender
{
    // Dismiss the keyboard if it is up
    [self.view endEditing:YES];

    // TODO - get the real video data and name - use a dummy for now
    NSString *str=[[NSBundle mainBundle] pathForResource:@"IMG_0315" ofType:@"MOV"];
    NSData *videoData = [NSData dataWithContentsOfFile:str ];

    // Push to S3
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:@"IMG_0315" inBucket:@"group13videos-akiajjh522j3c3god2va"];
    por.contentType = @"video/quicktime";
    por.data = videoData;
    por.delegate = self;
    [self.s3 putObject:por];
    NSLog(@"Request sent");
    
    // Start spinning the progress bar
    [DejalBezelActivityView activityViewForView:self.navigationController.navigationBar.superview withLabel:@"Processing..."].showNetworkActivityIndicator = YES;;
    
}

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    NSLog(@"response 2: %@", response.description);
    
    [self getVideoUrl];
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"failure response: %@", error.description);
    
    // Stop spinning the progress bar
    [DejalBezelActivityView removeViewAnimated:YES];
}

- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    NSLog(@"didFailWithServiceException: %@", exception.description);
    
    // Stop spinning the progress bar
    [DejalBezelActivityView removeViewAnimated:YES];
}


- (void)getVideoUrl
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        // Get the URL
        // Set the content type so that the browser will treat the URL as an image.
        S3ResponseHeaderOverrides *override = [[S3ResponseHeaderOverrides alloc] init];
        override.contentType = @"video/quicktime";
        
        // Request a pre-signed URL to picture that has been uplaoded.
        S3GetPreSignedURLRequest *gpsur = [[S3GetPreSignedURLRequest alloc] init];
        gpsur.key                     = @"IMG_0315";
        gpsur.bucket                  = @"group13videos-akiajjh522j3c3god2va";
        gpsur.expires                 = [NSDate dateWithTimeIntervalSinceNow:(NSTimeInterval) 630720000]; // Added 20yrs worth of seconds to the current time.
        gpsur.responseHeaderOverrides = override;
        
        // Get the URL
        NSError *error = nil;
        NSURL *url = [self.s3 getPreSignedURL:gpsur error:&error];
        
        if(url == nil)
        {
            if(error != nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"Error: %@", error);
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // Display the URL in Safari
                [self saveVideoToParse:[url absoluteString]];
            });
        }
        
    });
}

- (void)saveVideoToParse:(NSString *)url
{
    // Create a PFObject around a PFFile and associate it with the current user
    PFObject *userVideo = [PFObject objectWithClassName:@"UserVideo"];
    
    // Set the access control list to current user for security purposes
    userVideo.ACL = [PFACL ACLWithUser:[PFUser currentUser]];
    
    PFUser *user = [PFUser currentUser];
    [userVideo setObject:user forKey:@"user"];
    userVideo[@"title"] = self.videoTitleTextField.text;
    userVideo[@"videoUrl"] = url;
    userVideo[@"duration"] = @"1:34";
    [userVideo saveInBackground];

    
    // Stop spinning the progress bar
    [DejalBezelActivityView removeViewAnimated:YES];
    
    // Go to the video list
    [self performSegueWithIdentifier:@"createToVideoListSegue" sender:nil];
  
}


@end
