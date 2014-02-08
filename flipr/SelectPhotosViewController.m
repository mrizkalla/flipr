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
#import <AssetsLibrary/AssetsLibrary.h>

static int counter;

@interface SelectPhotosViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *photoSourceSegmentControl;

@property (strong, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (nonatomic, strong) NSMutableArray *flickrImageResults;
@property (nonatomic,strong) NSMutableArray *cameraImageResults;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;



- (IBAction)photoSourceValueChanged:(id)sender;
- (void) onSignIn;
- (void)onError;
- (void) getUserPhotos;
-(void) requestFlickrImage: (NSIndexPath *) indexPath;
-(void) putFlickrImage:(NSDictionary * )params;
- (ALAssetsLibrary *)defaultAssetsLibrary;

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
    
    
    //Setting up the photoSource
    self.photoSourceSegmentControl.selectedSegmentIndex = 0;
    
    
    //Loading the camera roll photos in the cameraImageResults first
    _cameraImageResults = [@[] mutableCopy];
    __block NSMutableArray *tmpAssets = [@[] mutableCopy];
    ALAssetsLibrary *assetsLibrary = [self defaultAssetsLibrary];
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if(result)
            {
                [tmpAssets addObject:result];
            }
        }];
        self.cameraImageResults = tmpAssets;
        [self.photosCollectionView reloadData];
    }failureBlock:^(NSError *error) {
        NSLog(@"Error loading camera images %@", error);
    }];
}
    

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)photoSourceValueChanged:(id)sender {
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        NSLog(@"Selected Camera roll");
        [self.photosCollectionView reloadData];
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
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        return self.cameraImageResults.count;
    }
    else{
        return [self.flickrImageResults count];
    }
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *CellIdentifier = @"FlickrCell";
    
    //Dequeue or create cell of appropriate type
    FlickrCell*cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.flickrPhotoImageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.flickrPhotoImageView.layer.masksToBounds = YES;
    cell.photoCaption.delegate = self;
    
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        cell.backgroundColor = [UIColor whiteColor];
        ALAsset *asset = self.cameraImageResults[indexPath.row];
        
        cell.flickrPhotoImageView.image = [UIImage imageWithCGImage:[asset thumbnail]];
        
        
    }
        
    else{
        cell.backgroundColor = [UIColor whiteColor];
        //FlickrPhoto *fp = self.flickrImageResults[indexPath.row];
    
       
    
        //Setting the flickr photo in the background process
        [self performSelectorInBackground:@selector(requestFlickrImage:) withObject:indexPath];
    }

 
    
    return cell;
    
}

#pragma mark - Image loading Methods
-(void) requestFlickrImage: (NSIndexPath *) indexPath{
    
    //NSLog (@"In request profile method");
    
    FlickrPhoto *currPhoto = [self.flickrImageResults objectAtIndex:indexPath.row];
    NSURL *imageURL =  [NSURL URLWithString:currPhoto.photoURL];
    NSData *imageData = [[NSData alloc] initWithContentsOfURL: imageURL];
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:indexPath,image,nil] forKeys:[NSArray arrayWithObjects:@"indexPath",@"image", nil]];
    
    [self performSelectorOnMainThread:@selector(putFlickrImage:) withObject:params waitUntilDone:NO];
    
}

-(void) putFlickrImage:(NSDictionary * )params {
    
    // NSLog (@"In put Profile method");
    
    NSIndexPath *indexPath = [params valueForKeyPath:@"indexPath"];
    UIImage *image = [params valueForKeyPath:@"image"];
    
    //NSLog (@"The row is :%u",indexPath.row);
    UICollectionViewCell *fromcell =  [self.photosCollectionView cellForItemAtIndexPath:indexPath];
    FlickrCell *cell = (FlickrCell *) fromcell;
    [cell.flickrPhotoImageView setImage:image];
    
    
}



#pragma mark -UICollectiovViewFlowLayout delegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize retval;
    retval = CGSizeMake(150, 150);
    return retval;
    
}

#pragma mark - UICollection view selection methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath: %@", indexPath);
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        [self.selectedPhotos addObject:[self.cameraImageResults objectAtIndex:[indexPath row]]];
    }else{
        NSLog(@"flickrImageSelected %@", self.selectedPhotos);
        [self.selectedPhotos addObject:[self.flickrImageResults objectAtIndex:[indexPath row]]];
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(self.photoSourceSegmentControl.selectedSegmentIndex == 0){
        [self.selectedPhotos removeObject:[self.cameraImageResults objectAtIndex:[indexPath row]]];
        
    }else{
        [self.selectedPhotos removeObject:[self.flickrImageResults objectAtIndex:[indexPath row]]];
        NSLog(@"flickrImageSelected %@", self.selectedPhotos);
    }

}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CreateVideo"]) {
        CreateVideoViewController *creatVideoViewController = segue.destinationViewController;
        creatVideoViewController.selectedPhotos = self.selectedPhotos;
    }
}


#pragma mark - Camera Roll methods
- (ALAssetsLibrary *)defaultAssetsLibrary
{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




@end
