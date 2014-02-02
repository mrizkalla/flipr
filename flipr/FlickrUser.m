//
//  FlickrUser.m
//  flipr
//
//  Created by Priyanka Bhalerao on 2/1/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "FlickrUSer.h"
#import "FlickrClient.h"

NSString * const FlickrUserDidLoginNotification = @"FlickrUserDidLoginNotification";
NSString * const FlickrUserDidLogoutNotification = @"FlickrUserDidLogoutNotification";
NSString * const kCurrentFlickrUserKey = @"kCurrentFlickrUserKey";

@implementation FlickrUser

static FlickrUser *_currentFlickrUser;

+ (FlickrUser *)currentFlickrUser {
    if (!_currentFlickrUser) {
        NSData *FlickrUserData = [[NSUserDefaults standardUserDefaults] dataForKey:kCurrentFlickrUserKey];
        if (FlickrUserData) {
            NSDictionary *userDictionary = [NSJSONSerialization JSONObjectWithData:FlickrUserData options:NSJSONReadingMutableContainers error:nil];
            _currentFlickrUser = [[FlickrUser alloc] initWithDictionary:userDictionary];
        }
    }
    
    return _currentFlickrUser;
}

+ (void)setCurrentFlickrUser:(FlickrUser *)currentFlickrUser {
    if (currentFlickrUser) {
        NSData *userData = [NSJSONSerialization dataWithJSONObject:currentFlickrUser.data options:NSJSONWritingPrettyPrinted error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:userData forKey:kCurrentFlickrUserKey];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCurrentFlickrUserKey];
        [FlickrClient instance].accessToken = nil;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (!_currentFlickrUser && currentFlickrUser) {
        _currentFlickrUser = currentFlickrUser; // Needs to be set before firing the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:FlickrUserDidLoginNotification object:nil];
    } else if (_currentFlickrUser && !currentFlickrUser) {
        _currentFlickrUser = currentFlickrUser; // Needs to be set before firing the notification
        [[NSNotificationCenter defaultCenter] postNotificationName:FlickrUserDidLogoutNotification object:nil];
    }
}

@end

