//
//  VideoCreator.h
//  flipr
//
//  Created by Michael Rizkalla on 2/10/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoCreator : NSObject

- (void)createVideo:(NSArray *)imageArray;
- (NSURL*)getVideoURL;
- (CGImageRef)getCoverPhotoRef;

@end
