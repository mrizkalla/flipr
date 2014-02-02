//
//  FlickrPhoto.m
//  flipr
//
//  Created by Priyanka Bhalerao on 2/2/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "FlickrPhoto.h"

@implementation FlickrPhoto

- (NSString *)photoURL {
    NSString* photoSecret = [self.data valueOrNilForKeyPath:@"secret"];
    NSString * photoId = [self.data valueOrNilForKeyPath:@"id"];
    NSString *photoFarm = [self.data valueOrNilForKeyPath:@"farm"];
    NSString *photoServer = [self.data valueOrNilForKeyPath:@"server"];
    
    NSString *photoURL = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@_m.jpg",photoFarm,photoServer,photoId,photoSecret];
    return photoURL;
}

+ (NSMutableArray *)photosWithArray:(NSArray *)array {
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (NSDictionary *params in array) {
        [photos addObject:[[FlickrPhoto alloc] initWithDictionary:params]];
    }
    return photos;
}
@end
