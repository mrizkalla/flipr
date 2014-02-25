//
//  VideoCreator.m
//  flipr
//
//  Created by Michael Rizkalla on 2/10/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "VideoCreator.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoCreator ()

@property (nonatomic, strong) NSArray *selectedPhotos;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@property (nonatomic, strong) AVAssetWriterInput* writerInput;
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) NSString *appFile;
@property (nonatomic,strong) NSString *musicFile;
@property (nonatomic,strong) NSString *movFile;

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image andSize:(CGSize)size;
- (void)saveMovieToCameraRoll;
- (CGImageRef)addText:(CGImageRef)img text:(NSString *)text1;


@end

@implementation VideoCreator

- (id)init
{
    self = [super init];
    if (self) {
        // Get the path of the file to write
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        self.appFile = [documentsDirectory stringByAppendingPathComponent:@"MyFile.mov"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *error = nil;
        
        if ([fileMgr removeItemAtPath:self.appFile error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        
        self.videoWriter = [[AVAssetWriter alloc] initWithURL:
                                      [NSURL fileURLWithPath:self.appFile] fileType:AVFileTypeQuickTimeMovie
                                                                  error:&error];
        // Start - Added for audio
        self.movFile = [documentsDirectory stringByAppendingPathComponent:@"MyMovFile.mov"];
        
        if ([fileMgr removeItemAtPath:self.movFile error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        
        // End

        NSParameterAssert(self.videoWriter);
        
        
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       AVVideoCodecH264, AVVideoCodecKey,
                                       [NSNumber numberWithInt:640], AVVideoWidthKey,
                                       [NSNumber numberWithInt:480], AVVideoHeightKey,
                                       //compressionProperties, AVVideoCompressionPropertiesKey,
                                       nil];
        self.writerInput = [AVAssetWriterInput
                            assetWriterInputWithMediaType:AVMediaTypeVideo
                            outputSettings:videoSettings];
        self.adaptor = [AVAssetWriterInputPixelBufferAdaptor
                        assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerInput
                        sourcePixelBufferAttributes:nil];
        
        NSParameterAssert(self.writerInput);
        NSParameterAssert([self.videoWriter canAddInput:self.writerInput]);
        [self.videoWriter addInput:self.writerInput];
        
        [self.videoWriter startWriting];
        [self.videoWriter startSessionAtSourceTime:kCMTimeZero];
        
    }
    
    return self;
}

- (void)createVideo:(NSArray *)imageArray {
    
    self.selectedPhotos = imageArray;

    //Video encoding
    
    CVPixelBufferRef buffer = NULL;
    if (buffer == NULL) {
        CVPixelBufferPoolCreatePixelBuffer (NULL, self.adaptor.pixelBufferPool, &buffer);
    }
    //convert uiimage to CGImage.
    
    int frameCount = 0;
    double numberOfSecondsPerFrame = 3;
    NSUInteger fps = 30;
    double frameDuration = fps * numberOfSecondsPerFrame;
    
    CGSize size = CGSizeMake(640, 480);

    
    for(id object in self.selectedPhotos) {
        NSURL *urlStr;
        NSString *photoText = @"";
        CGImageRef imref = Nil;
        
        if([object isKindOfClass:[FlickrPhoto class]]) {
            FlickrPhoto *myFp = object;
            urlStr = [NSURL URLWithString:myFp.photoURL];
            if(myFp.photoCaption){
                photoText = myFp.photoCaption;
            }
            NSLog(@"The url for flickr photo is :%@ and the caption is : %@",urlStr,photoText);
            //imref = [[UIImage imageWithData:[NSData dataWithContentsOfURL:urlStr]] CGImage];
            NSData *nsData = [NSData dataWithContentsOfURL:urlStr];
            
            UIImage *image = [UIImage imageWithData: nsData];
            imref = image.CGImage;
            
        } else if([object isKindOfClass:[CameraPhoto class]]) {
            
            ALAsset *myCameraPhoto = object;
            urlStr = myCameraPhoto.defaultRepresentation.url;
            CameraPhoto *myCp = object;
            //urlStr = [NSURL URLWithString:myCameraPhoto.photoURL];
            //urlStr = [NSURL URLWithString:@""];
            if(myCp.photoCaption){
                photoText= myCp.photoCaption;
            }
            NSLog(@"The url for camera photo is :%@ and the caption is :%@",urlStr,photoText);
            ALAssetRepresentation *rep = [myCameraPhoto defaultRepresentation];
            imref = [rep fullResolutionImage];
        }            
        // Put the caption on the image
        if (photoText.length != 0) {
            CGImageRef imref2 = [self addText:imref text:photoText];
            buffer = [self pixelBufferFromCGImage:imref2 andSize:size];
        } else {
            buffer = [self pixelBufferFromCGImage:imref andSize:size];
        }
        
        BOOL append_ok = NO;
        int j = 0;
        while (!append_ok && j < 30) {
            if (self.adaptor.assetWriterInput.readyForMoreMediaData) {
                NSLog(@"appending %d attemp %d\n", frameCount, j);
                
                //CMTime frameTime = CMTimeMake(frameCount*100,(int32_t) 10);
                CMTime frameTime = CMTimeMake(frameCount*frameDuration,(int32_t) fps);
                
                append_ok = [self.adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                CVPixelBufferPoolRef bufferPool = self.adaptor.pixelBufferPool;
                NSParameterAssert(bufferPool != NULL);
                
                //[NSThread sleepForTimeInterval:0.05];
            }
            else {
                printf("adaptor not ready %d, %d\n", frameCount, j);
                [NSThread sleepForTimeInterval:0.1];
            }
            j++;
        }
        if (!append_ok) {
            printf("error appending image %d times %d\n", frameCount, j);
        }
        frameCount++;
        CVBufferRelease(buffer);
    }
    
    [self.writerInput markAsFinished];
    //get the iOS version of the device
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version < 6.0)
    {
        [self.videoWriter finishWriting];
        //NSLog (@"finished writing iOS version:%f",version);
        
    } else {
        [self.videoWriter finishWritingWithCompletionHandler:^(){
            //NSLog (@"finished writing iOS version:%f",version);
        }];
    }
    
    
    
    //OK now add an audio file to move file
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    //Get the saved audio song path to merge it in video
    NSURL *audio_inputFileUrl ;
    self.musicFile = [[NSBundle mainBundle] pathForResource:@"mysong" ofType:@"mp3"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
   // NSError *error = nil;
    //NSString *outputFilePath1 = [filePath stringByAppendingPathComponent:@"mySong.m4a"];
    audio_inputFileUrl = [[NSURL alloc]initFileURLWithPath:self.musicFile];
    
    bool audioExists = [ fileMgr fileExistsAtPath:self.musicFile];
    if(audioExists){
         NSLog(@"Audio file %@ exists",self.musicFile);
    }else{
        NSLog(@"Audio file %@ does not exist",self.musicFile);
    }
    // this is the video file that was just written above
    NSURL    *video_inputFileUrl = [[NSURL alloc]initFileURLWithPath:self.appFile];
    
    [NSThread sleepForTimeInterval:0.5];
    
    // create the final video output file as MOV file - may need to be MP4, but this works so far...
    //    NSString *outputFilePath = [documentsDirectory stringByAppendingPathComponent:@"Slideshow_video.mov"];
    //    NSURL    *outputFileUrl = [[NSURL alloc]initFileURLWithPath:outputFilePath];
    
    //    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
    //        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
     
    
    //AVURLAsset get video without audio
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:video_inputFileUrl options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    [NSThread sleepForTimeInterval:0.5];
    
    //If audio song merged
    //if (![self.appDelegate.musicFilePath isEqualToString:@"Not set"])
    if (![self.musicFile isEqualToString:@""])
    {
     
     NSLog(@"Adding the audio to the video -step 1");
     AVURLAsset* audioAsset = [[AVURLAsset alloc]initWithURL:audio_inputFileUrl options:nil];
     CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
     AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
     
     if (![audioAsset tracksWithMediaType:AVMediaTypeAudio].count == 0) {
         NSLog(@"Adding the audio to the video -step 2");
     [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
     }
    }
    
    
    [NSThread sleepForTimeInterval:0.5];
    
    
    //AVAssetExportSession to export the video
     AVAssetExportSession* assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
     assetExport.outputFileType = AVFileTypeQuickTimeMovie;
     NSURL    *outputFileUrl = [NSURL fileURLWithPath:self.movFile];
     assetExport.outputURL = outputFileUrl;
     
     [assetExport exportAsynchronouslyWithCompletionHandler:^(void){
      
     
     
     switch (assetExport.status) {
         case AVAssetExportSessionStatusCompleted:
         //#if !TARGET_IPHONE_SIMULATOR
         //[self saveMo   vieToCameraRoll:outputFileUrl];
         //#endif
         //[self RemoveSlideshowImagesInTemp];
         //[self removeAudioFileFromDocumentsdirectory:outputFilePath1];
         //[self removeAudioFileFromDocumentsdirectory:videoOutputPath];
         NSLog(@"AVAssetExportSessionStatusCompleted");
         dispatch_async(dispatch_get_main_queue(), ^{
         // if (alrtCreatingVideo && alrtCreatingVideo.visible) {
         //[alrtCreatingVideo dismissWithClickedButtonIndex:alrtCreatingVideo.firstOtherButtonIndex animated:YES];
         //[databaseObj isVideoCreated:appDelegate.pro_id];
         //[self performSelector:@selector(successAlertView) withObject:nil afterDelay:0.0];
         //}
         });
         break;
         case AVAssetExportSessionStatusFailed:
         NSLog(@"Failed:%@",assetExport.error);
         break;
         case AVAssetExportSessionStatusCancelled:
         NSLog(@"Canceled:%@",assetExport.error);
         break;
         default:
         break;
     }
     }];
    
    

    // [self saveMovieToCameraRoll];
    
    
    
    
}

-(CGImageRef)addText:(CGImageRef)img text:(NSString *)text1{
    
    UIImage* image = [[UIImage alloc] initWithCGImage:img];
    UIFont *font = [UIFont boldSystemFontOfSize:14];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(20, image.size.height - 30, image.size.width, image.size.height);

    [text1 drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:font,
                                                            NSForegroundColorAttributeName:[UIColor whiteColor]
                                                            }];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return [newImage CGImage];
}


- (CVPixelBufferRef) pixelBufferFromCGImage:(CGImageRef)image andSize:(CGSize)frameSize
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    //CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width,
    //                                    frameSize.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options,
    //                                  &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    
    //CGContextConcatCTM(context, CGAffineTransformMakeScale(0,0));
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (void)saveMovieToCameraRoll
{

    NSURL *outputURL = [NSURL fileURLWithPath:self.movFile];
    
    // save the movie to the camera roll
	ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	NSLog(@"writing \"%@\" to photos album", outputURL);
	[library writeVideoAtPathToSavedPhotosAlbum:outputURL
								completionBlock:^(NSURL *assetURL, NSError *error) {
									if (error) {
										NSLog(@"assets library failed (%@)", error);
									}
									else {
										//[[NSFileManager defaultManager] removeItemAtURL:outputURL error:&error];
										if (error)
											NSLog(@"Couldn't remove temporary movie file \"%@\"", outputURL);
									}
								}];
}

- (NSURL *)getVideoURL {
//return [NSURL fileURLWithPath:self.appFile];
    return [NSURL fileURLWithPath:self.movFile];
}

- (NSURL *)getonlyVideoURL{
    return [NSURL fileURLWithPath:self.appFile];
    
}

@end