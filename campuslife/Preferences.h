//
//  Preferences.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject

@property (nonatomic, setter = initPrefs:)NSMutableDictionary *prefs;

+(Preferences *) getSharedInstance;

- (BOOL) getPreference:(NSString *)prefName;
- (void) negatePreference:(NSString *)prefName;

- (void) loadPreferences;
- (void) savePreferences;

@end
