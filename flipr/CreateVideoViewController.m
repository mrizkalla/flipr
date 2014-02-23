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
#import <AssetsLibrary/AssetsLibrary.h>
#import "VideoCreator.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <AddressBook/AddressBook.h>

@interface CreateVideoViewController ()
@property (weak, nonatomic) IBOutlet UIView *videoCanvasView;
@property (weak, nonatomic) IBOutlet UITextField *videoTitleTextField;

@property (nonatomic, strong) AmazonS3Client *s3;
@property (nonatomic, strong) VideoCreator *vc;
@property (nonatomic, strong) NSString *uniqueKey;
@property (nonatomic, strong) MPMoviePlayerController *player;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
- (IBAction)onShare:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
- (IBAction)onEmail:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *uploadLabel;

@property (nonatomic, strong) NSString *parseURL;

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
    
    self.vc = [[VideoCreator alloc] init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self.vc createVideo:self.selectedPhotos];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Put the video up in the box now %@", [self.vc getVideoURL]);
            self.player = [[MPMoviePlayerController alloc] initWithContentURL:[self.vc getVideoURL]];
            self.player.movieSourceType = MPMovieSourceTypeFile;

            [self.player prepareToPlay];

            //player.view.frame = CGRectMake(0, 0, self.videoCanvasView.frame.size.width, self.videoCanvasView.frame.size.height);
            [self.player.view setFrame:self.videoCanvasView.bounds];


            
            [self.videoCanvasView addSubview:self.player.view];

            [self.player play];
 
            
              // player's frame must match parent's
            
            // Configure the movie player controller
        });
    });
    
    //Set all the share options to hidden
    self.shareButton.hidden = YES;
    self.uploadLabel.hidden = YES;
    self.emailButton.hidden = YES;
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Sharing options
- (IBAction)onShare:(id)sender {
    NSLog(@"The video file is :%@",[self.vc getVideoURL]);
    
    [[FlickrClient instance] uploadFlickrPhotoWithFile:[self.vc getVideoURL] title:self.videoTitleTextField.text success:^(AFHTTPRequestOperation *operation, id response) {
        
        id results = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
       // id photos = [[ results objectForKey:@"photos"] objectForKey:@"photo"];
        NSLog(@"Upload response: %@", response);
      
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
        NSLog(@"Flickr video failed to upload");
    }];

}
#pragma mark Email methods
- (IBAction)onEmail:(id)sender {
    
    //Getting user's email address in this step:
    //NSString *userEmailAddress = @"";
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil,nil);
 
   
    
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Flipr Video!"];
	
	// Set up recipients
    /*
	NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"];
	NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
	NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
	
	[picker setToRecipients:toRecipients];
	[picker setCcRecipients:ccRecipients];
	[picker setBccRecipients:bccRecipients];*/

	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"Look at this cool video by flipr :%@",self.parseURL];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentViewController:picker animated:YES completion:NULL];

}
#pragma mark - EmailCompose Delegate Methods

// -------------------------------------------------------------------------------
//	mailComposeController:didFinishWithResult:
//  Dismisses the email composition interface when users tap Cancel or Send.
//  Proceeds to update the message field with the result of the operation.
// -------------------------------------------------------------------------------
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	
	// Notifies users about errors associated with the interface
     NSString *message = [NSString stringWithFormat:@""];
	switch (result)
	{
           
		case MFMailComposeResultCancelled:
			message = @"Result: Mail sending canceled";
          
			break;
		case MFMailComposeResultSaved:
			message= @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			message = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			message = @"Result: Mail sending failed";
			break;
		default:
			message = @"Result: Mail not sent";
			break;
	}
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email Status"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    
	[self dismissViewControllerAnimated:YES completion:NULL];
    [alert show];
    [self performSegueWithIdentifier:@"createToVideoListSegue" sender:nil];
}



- (IBAction)onDoneButton:(id)sender
{
    // Dismiss the keyboard if it is up
    [self.view endEditing:YES];

    // Check that there is a title and if there isn't alert the dude
    if (self.videoTitleTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Video Title"
                                                        message:@"You must set a title for your awesome creation."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    // TODO - get the real video data and name - use a dummy for now
    NSData *videoData = [NSData dataWithContentsOfURL:[self.vc getVideoURL]];

    // Push to S3
    self.uniqueKey = [NSString stringWithFormat:@"%@.%f",[[PFUser currentUser] username], [[NSDate date] timeIntervalSince1970]];
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:self.uniqueKey inBucket:@"group13videos-akiajjh522j3c3god2va"];
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
        gpsur.key                     = self.uniqueKey;
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
                self.parseURL = [url absoluteString];
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
    
    // Get the Duration
    NSURL *sourceMovieURL = [self.vc getVideoURL];
    AVURLAsset *sourceAsset = [AVURLAsset URLAssetWithURL:sourceMovieURL options:nil];
    CMTime duration = sourceAsset.duration;
    NSDate* d = [[NSDate alloc] initWithTimeIntervalSince1970:duration.value/duration.timescale];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    userVideo[@"duration"] = [dateFormatter stringFromDate:d];
    
    // Send to parse
    [userVideo saveInBackground];

    
    // Stop spinning the progress bar
    [DejalBezelActivityView removeViewAnimated:YES];
    
    self.shareButton.hidden = NO;
    self.uploadLabel.hidden = NO;
    self.emailButton.hidden = NO;
    
    // Go to the video list
  //  [self performSegueWithIdentifier:@"createToVideoListSegue" sender:nil];
  
}


@end
