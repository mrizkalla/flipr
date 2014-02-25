//
//  FlickrUser.h
//  flipr
//
//  Created by Priyanka Bhalerao on 2/1/14.
//  Copyright (c) 2014 yahoo. All rights reserved.
//

#import "RestObject.h"

extern NSString *const FlickrUserDidLoginNotification;
extern NSString *const FlickrUserDidLogoutNotification;

@interface FlickrUser : RestObject

+ (FlickrUser *)currentFlickrUser;
+ (void)setCurrentFlickrUser:(FlickrUser *)currentFlickrUser;

@end
