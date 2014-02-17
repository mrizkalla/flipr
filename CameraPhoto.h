//
//  CameraPhoto.h
//  flipr
//
//  Created by Priyanka Bhalerao on 2/16/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//
#import "RestObject.h"

@interface CameraPhoto : RestObject

@property (nonatomic, strong, readonly) NSString *photoURL;
@property (nonatomic, strong) NSString *photoCaption;

+ (NSMutableArray *)photosWithArray:(NSArray *)array;


@end
