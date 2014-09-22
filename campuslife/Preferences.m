//
//  Preferences.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Preferences.h"
#import "Authentication.h"

@implementation Preferences

static Preferences *_sharedInstance;

+(Preferences *) getSharedInstance
{
    if (!_sharedInstance)
    {
        _sharedInstance = [[Preferences alloc] init];
        
        [_sharedInstance initPrefs];
        
        //Then load the preferences from previous sessions of the app.
        [_sharedInstance loadPreferences];
    }
    
    return _sharedInstance;
}



- (void) initPrefs
{
    _prefs = [[NSMutableDictionary alloc] init];
    
    NSUInteger keyCount = [[[Authentication getSharedInstance] getCategoryNames] count];
    
    for ( int i = 0; i < keyCount; i++ )
    {
        [_prefs setObject:@1 forKey:[[Authentication getSharedInstance] getCategoryNames][i]];
    }
}



/*- (void) setPreference:(NSString *)prefName :(BOOL)isSelected
{
    
    
    switch(index) {
        case 1:
            [self setPrefOne:isSelected];
            break;
        case 2:
            [self setPrefTwo:isSelected];
            break;
        case 3:
            [self setPrefThree:isSelected];
            break;
        case 4:
            [self setPrefFour:isSelected];
            break;
        case 5:
            [self setPrefFive:isSelected];
            break;
        case 6:
            [self setPrefSix:isSelected];
            break;
    }
}*/



/*
 Negates the current preference turning it from on to off or vice-versa.
 @param prefName Name of the category.
 */
- (void) negatePreference:(NSString *)prefName
{
    BOOL value = ![[_prefs valueForKey:prefName] boolValue];
    
    [_prefs setValue:[NSNumber numberWithBool:value] forKey:prefName];
}


/*
 Retrieves the value of the preference from the dictionary.
 @param prefName  Name of the category.
 @return Boolean value for the state of the preference.
 */
- (BOOL) getPreference:(NSString *)prefName
{
    BOOL isSelected = [[_prefs valueForKey:prefName] boolValue];
    
    return isSelected;
}



//This is called when the instance is being initialized. Nowhere else. So it only loads once.
//The preferences are negated when being loaded, because a NO is returned when the object doesn't exist.
//  I want there to be a YES being returned by default. So when prefs are saved, they are negated and
//  when they're loaded they're being negated again to get the original state (but the default is YES instead of NO.)
- (void) loadPreferences
{
    //This is an object that we'll be loading our saved data from.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Tracks the number of times the for-loop should execute.
    NSUInteger each = [_prefs count];
    
    //Load all of the prefences for the categories that are selected.
    for (int i = 0; i < each; i++)
    {
        NSNumber *prefActive = [NSNumber numberWithBool:![defaults boolForKey:[[Authentication getSharedInstance] getCategoryNames][i]]];
        
        [_prefs setValue:prefActive forKey:[[Authentication getSharedInstance] getCategoryNames][i]];
    }
}



//This is called within AppDelegate when the app is being closed or brought to the background.
//The preferences are negated when being saved, because a NO is returned when the object doesn't exist.
//  I want there to be a YES being returned by default. So when prefs are saved, they are negated and
//  when they're loaded they're being negated again to get the original state (but the default is YES instead of NO.)
- (void) savePreferences
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //Tracks the number of times the for-loop should execute.
    NSUInteger each = [_prefs count];
    
    //Save the preferences for future sessions of the app.
    for (int i = 0; i < each; i++)
    {
        //Retrieves current value for key, or if none exists returns 0 - then typecasted into Bool.
        BOOL prefActive = [[_prefs valueForKey:[[Authentication getSharedInstance] getCategoryNames][i]] boolValue];
        
        //Sets the boolean value for key.
        [defaults setBool:!prefActive forKey:[[Authentication getSharedInstance] getCategoryNames][i]];
    }
    
    [defaults synchronize];
}



@end
