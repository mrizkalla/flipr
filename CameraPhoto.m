//
//  CameraPhoto.m
//  flipr
//
//  Created by Priyanka Bhalerao on 2/16/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//



@implementation CameraPhoto


+ (NSMutableArray *)photosWithArray:(NSArray *)array {
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        //[photos addObject:[[CameraPhoto] alloc] params ]
        [photos addObject:[[CameraPhoto alloc] initWithDictionary:params]];
    }
    return photos;
}
@end
