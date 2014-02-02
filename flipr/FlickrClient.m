//
//  FlickrClient.m
//  flipr
//
//  Created by Priyanka Bhalerao on 2/1/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//


#import "FlickrClient.h"
#import "AFNetworking.h"

#define Flickr_BASE_URL [NSURL URLWithString:@"http://api.flickr.com/services/"]
#define Flickr_CONSUMER_KEY @"4bd736859f80395fc05acdf10abb3583"
#define Flickr_CONSUMER_SECRET @"82b3805206d7dd8a"




static NSString * const kAccessTokenKey = @"kAccessTokenKey";

@implementation FlickrClient

+ (FlickrClient *)instance {
    static dispatch_once_t once;
    static FlickrClient *instance;
    
    dispatch_once(&once, ^{
        instance = [[FlickrClient alloc] initWithBaseURL:Flickr_BASE_URL key:Flickr_CONSUMER_KEY secret:Flickr_CONSUMER_SECRET];
    });
    
    return instance;
}

- (id)initWithBaseURL:(NSURL *)url key:(NSString *)key secret:(NSString *)secret {
    self = [super initWithBaseURL:Flickr_BASE_URL key:Flickr_CONSUMER_KEY secret:Flickr_CONSUMER_SECRET];
    if (self != nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kAccessTokenKey];
        if (data) {
            self.accessToken = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return self;
}

#pragma mark - Users API

- (void)authorizeWithCallbackUrl:(NSURL *)callbackUrl success:(void (^)(AFOAuth1Token *accessToken, id responseObject))success failure:(void (^)(NSError *error))failure {
    self.accessToken = nil;
    [super authorizeUsingOAuthWithRequestTokenPath:@"oauth/request_token" userAuthorizationPath:@"oauth/authorize" callbackURL:callbackUrl accessTokenPath:@"oauth/access_token" accessMethod:@"POST" scope:nil success:success failure:failure];
}

- (void)currentUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"rest/?method=flickr.test.login&api_key=%@&format=json&nojsoncallback=1",Flickr_CONSUMER_KEY];
    [self getPath:url parameters:nil success:success failure:failure];
    
}

#pragma mark - Statuses API
- (void)getFlickrPhotosWithCount:(int)count success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"rest/?method=flickr.photos.search&api_key=%@&user_id=%@&format=json&nojsoncallback=1",Flickr_CONSUMER_KEY,@"me"];
    
    [self getPath:url parameters:nil success:success failure:failure];
}

#pragma mark - Private methods

- (void)setAccessToken:(AFOAuth1Token *)accessToken {
    [super setAccessToken:accessToken];
    
    if (accessToken) {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:accessToken];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAccessTokenKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAccessTokenKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


@end
