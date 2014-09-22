//
//  Authentication.h
//  campuslife
//
//  Created by Super Student on 12/3/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoogleOAuth.h"

@interface Authentication : NSObject


// A GoogleOAuth object that handles everything regarding the Google.
@property (nonatomic, strong) GoogleOAuth *googleOAuth;

//Is for determining if the user can manage events.
@property (nonatomic, getter=getUserCanManageEvents, setter=setUserCanManageEvents:) BOOL userCanManageEvents;

@property (nonatomic, strong, setter=setCalIds:, getter=getCalIds) NSDictionary *calendarIds;

@property (nonatomic, strong, setter=setEventIds:, getter=getEventIds) NSDictionary *authorizationEventIds;

@property (nonatomic, strong, setter=setAuthCals:, getter=getAuthCals) NSMutableDictionary *authorizedCalendars;

@property (nonatomic, strong, setter=setCategoryNames:, getter=getCategoryNames) NSArray *categoryNames;

+(Authentication *) getSharedInstance;

-(GoogleOAuth *) getAuthenticator;

-(void) setAuthenticator:(GoogleOAuth *)authenticator;

-(void) setDelegate:(UIViewController<GoogleOAuthDelegate> *)delegate;

-(void) resetPriviledges;
@end
