//
//  Preferences.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/19/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Preferences.h"
#import "CalendarInfo.h"

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
    
    NSArray *categoryNames = [CalendarInfo getCategoryNames];
    NSUInteger keyCount = [categoryNames count];
    
    for ( int i = 0; i < keyCount; i++ )
    {
        [_prefs setObject:@0 forKey:categoryNames[i]];
    }
}





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
    NSArray *categoryNames = [CalendarInfo getCategoryNames];
    for (int i = 0; i < each; i++)
    {
        NSNumber *prefActive = [NSNumber numberWithBool:![defaults boolForKey:categoryNames[i]]];
        
        [_prefs setValue:prefActive forKey:categoryNames[i]];
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
    NSArray *categoryNames = [CalendarInfo getCategoryNames];
    for (int i = 0; i < each; i++)
    {
        //Retrieves current value for key, or if none exists returns 0 - then typecasted into Bool.
        BOOL prefActive = [[_prefs valueForKey:categoryNames[i]] boolValue];
        
        //Sets the boolean value for key.
        [defaults setBool:!prefActive forKey:categoryNames[i]];
    }
    
    [defaults synchronize];
}



@end
