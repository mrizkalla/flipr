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
#define Flickr_UPLOAD_URL [NSURL URLWithString:@"http://up.flickr.com/services/"]




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
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"api_key": Flickr_CONSUMER_KEY}];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:@"1" forKey:@"nojsoncallback"];
    
    NSString *url = [NSString stringWithFormat:@"rest/?method=flickr.test.login"];
    [self getPath:url parameters:params success:success failure:failure];
    
}

#pragma mark - Flickr Photo and Video APIs
- (void)getFlickrPhotosWithCount:(int)count success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
     NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"api_key": Flickr_CONSUMER_KEY}];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:@"1" forKey:@"nojsoncallback"];
    [params setObject:@"me" forKey:@"user_id"];
    [params setObject:@"photos" forKey:@"media"];
    
    NSString *url = [NSString stringWithFormat:@"rest/?method=flickr.photos.search"];
    
    [self getPath:url parameters:params success:success failure:failure];
}
- (void)uploadFlickrPhotoWithFile:(NSURL *)file title:(NSString *)title success:(void (^)(AFHTTPRequestOperation *operation, id response))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    
    [self changeBaseUrl:Flickr_UPLOAD_URL];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"title": title}];
   // [params setObject:file forKey:@"photo"];
    [params setObject:@"file:///Users/bpriya/Pictures/babyElephant.jpg" forKey:@"photo"];
    NSString *postString = [NSString stringWithFormat:@"upload/"];
    
    [self postPath:postString parameters:params success:success failure:failure];
    
    [self changeBaseUrl:Flickr_BASE_URL];
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
