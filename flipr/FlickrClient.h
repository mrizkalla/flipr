//
//  FlickrClient.h
//  flipr
//
//  Created by Priyanka Bhalerao on 2/1/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "AFOAuth1Client.h"

@interface FlickrClient : AFOAuth1Client
+ (FlickrClient *)instance;

// Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure;

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getFlickrPhotosWithCount:(int)count success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
// Statuses API

@end
