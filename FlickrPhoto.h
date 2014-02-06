//
//  FlickrPhoto.h
//  flipr
//
//  Created by Priyanka Bhalerao on 2/2/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "RestObject.h"

@interface FlickrPhoto : RestObject

@property (nonatomic, strong, readonly) NSString *photoURL;

+ (NSMutableArray *)photosWithArray:(NSArray *)array;
@end
