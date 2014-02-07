//
//  SelectPhotosViewController.m
//  flipr
//
//  Created by Michael Rizkalla on 1/23/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "SelectPhotosViewController.h"
#import "FlickrCell.h"
#import "FlickrPhoto.h"
#import "DejalActivityView.h"
#import "CreateVideoViewController.h"

static int counter;

@interface SelectPhotosViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoSourceSegmentControl;

@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (nonatomic, strong) NSMutableArray *flickrImageResults;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;


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
    
    //Register custom cell nib
    UINib *customNib = [UINib nibWithNibName:@"FlickrCell" bundle:nil];
    [self.photosCollectionView registerNib:customNib forCellWithReuseIdentifier:@"FlickrCell"];
    
    self.photosCollectionView.dataSource=self;
    self.photosCollectionView.delegate=self;
    self.selectedPhotos = [@[] mutableCopy];
    counter = 0;
    [self.photosCollectionView reloadData];
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
            // Start spinning the progress bar
            [DejalBezelActivityView activityViewForView:self.navigationController.navigationBar.superview withLabel:@"Processing..."].showNetworkActivityIndicator = YES;
            
            [self getUserPhotos];
            
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

        id results = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
        id photos = [[ results objectForKey:@"photos"] objectForKey:@"photo"];
        NSLog(@"User pics: %@", photos);
        self.flickrImageResults = [FlickrPhoto photosWithArray:photos];
        [self.photosCollectionView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Do nothing
    }];
    
}

#pragma mark - UICollectionView methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

//Collection View method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    // Stop spinning the progress bar
    [DejalBezelActivityView removeViewAnimated:YES];
    [collectionView setAllowsMultipleSelection:YES];
    return [self.flickrImageResults count];
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"FlickrCell";
    
    //Dequeue or create cell of appropriate type
    FlickrCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    FlickrPhoto *fp = self.flickrImageResults[indexPath.row];

    
    cell.flickrPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;

    NSURL *fpURL =  [NSURL URLWithString:fp.photoURL];
    NSData *fpData = [[NSData alloc] initWithContentsOfURL: fpURL];
    UIImage *fpImage = [[UIImage alloc] initWithData:fpData];
    
    [cell.flickrPhotoImageView setImage:fpImage];
    
    return cell;
    
}


#pragma mark -UICollectiovViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize retval;
    retval = CGSizeMake(50, 50);
    
    return retval;
    
}

#pragma mark - NSNotification to select table cell

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath: %@", indexPath);
        
    [self.selectedPhotos addObject:[self.flickrImageResults objectAtIndex:[indexPath row]]];
    
    NSLog(@"flickrImageSelected %@", self.selectedPhotos);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.selectedPhotos removeObject:[self.flickrImageResults objectAtIndex:[indexPath row]]];
    
    NSLog(@"flickrImageSelected %@", self.selectedPhotos);

}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateVideo"]) {
        CreateVideoViewController *creatVideoViewController = segue.destinationViewController;
        creatVideoViewController.selectedPhotos = self.selectedPhotos;
    }
}

@end
