//
//  MonthlyEvents.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "MonthlyEvents.h"
#import "Preferences.h"


static MonthlyEvents *sharedInstance;


@interface MonthlyEvents ()

//This is a 3d array that holds three different 2d arrays. The 2d arrays hold events for each day in that month.
@property (nonatomic, strong, setter=setCalendarEvents:) NSMutableArray *calendarEvents;

//This holds three dictionaries that have a boolean for each calendar that represents whether the json has been received or not.
@property (nonatomic, strong, setter=setJsonReceivedDicts:) NSMutableArray *jsonReceivedDicts;

@property (nonatomic, setter=setFirstWeekDay0:) int firstWeekDay0;
@property (nonatomic, setter=setFirstWeekDay1:) int firstWeekDay1;
@property (nonatomic, setter=setFirstWeekDay2:) int firstWeekDay2;

@property (nonatomic, setter=setDaysInMonth:) NSMutableArray *daysInMonth;

@property (nonatomic, setter=setKnownOffsetForJan2013:) int knownOffsetForJan2013;

//This is strictly for the CalendarViewController to talk to the DayEventViewController (it's a work around.)
@property (nonatomic, setter=setDay:) int selectedDay;

@end

@implementation MonthlyEvents


+(MonthlyEvents *) getSharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[MonthlyEvents alloc] init];
        
        NSDate *date = [NSDate date];
        NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
        NSInteger year = [dateComponents year];
        NSInteger month = [dateComponents month];
        
        [sharedInstance setYear:(int)year];
        [sharedInstance setMonth:(int)month];
        
        //account for leap year.
        if (year % 4 == 0) {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @29, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        else {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        
        [sharedInstance setKnownOffsetForJan2013:2];
        
        [sharedInstance setCategoryNames:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Rec"]];
        
        [sharedInstance setCalIds:[[NSDictionary alloc] initWithObjectsAndKeys:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com", @"Academics",
                                    @"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com", @"Student Activities",
                                    @"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com", @"Warrior Athletics",
                                    @"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com", @"Entertainment",
                                    @"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com", @"Residence Life",
                                    @"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com", @"Campus Rec", nil]];
        
        /*CLAYTONNNNNNN THIS IS NOT NEEDED ANYMORE
         [sharedInstance setEventIds:[[NSDictionary alloc] initWithObjectsAndKeys:@"f1hgv90p23lu0qpk99jc2qksc8", @"Academics",
                                      @"dkl4s479ob9kv8364gnv9pn8ck", @"Student Activities",
                                      @"5ogvo7g7oudtnatvln1s0bbl7s", @"Warrior Athletics",
                                      @"k5lqhttcf8v6p6dtonbdmbnr98", @"Entertainment",
                                      @"r2ej4ok8qdohd1uqhpqjs3kp6o", @"Residence Life",
                                      @"pshph3m2oef72tmnk50i4enng0", @"Campus Rec", nil]];
        
        [sharedInstance setAuthCals:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"NO", @"Academics", @"NO", @"Student Activities", @"NO", @"Warrior Athletics", @"NO", @"Entertainment", @"NO", @"Residence Life", @"NO", @"Campus Rec", nil]];*/
        ////
        
        
        
        
        
        [sharedInstance setCalendarEvents:[[NSMutableArray alloc]initWithArray:@[[NSNull null], [NSNull null], [NSNull null]]]];
        
        
        NSMutableArray *jsonsReceived = [[NSMutableArray alloc] init];
        
        
        for (int i=0; i<3; i++)
        {
            NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
            for (int j=0; j<[[sharedInstance getCategoryNames] count]; j++)
            {
                [jsonDict setObject:@0 forKey:[sharedInstance getCategoryNames][j]];
            }
            [jsonsReceived addObject:jsonDict];
        }
        [sharedInstance setJsonReceivedDicts:jsonsReceived];
    }
    
        
        
    return sharedInstance;
}


-(void)resetEvents {
    _calendarEvents[0] = [NSNull null];
    _calendarEvents[1] = [NSNull null];
    _calendarEvents[2] = [NSNull null];
    
    for (int i=0; i<3; i++)
    {
        for (NSString *name in [sharedInstance getCategoryNames]) {
            _jsonReceivedDicts[i][name] = @0;
        }
    }
}

- (void) refreshArrayOfEvents:(int)arrayId {
    if (![_calendarEvents[arrayId] isEqual:[NSNull null]]) {
        [_calendarEvents[arrayId] removeAllObjects];
    }
    else {
        _calendarEvents[arrayId] = [[NSMutableArray alloc]init];
    }
    
    int monthOffset = arrayId-1;
    int yearOffset = 0;
    
    if (monthOffset+_selectedMonth == 0)
    {
        yearOffset = -1;
        monthOffset = 11;
    }
    else if (monthOffset+_selectedMonth == 13)
    {
        yearOffset = 1;
        monthOffset = -11;
    }
    
    int firstWeekday = 0;
    
    if (_selectedYear+yearOffset >= 2013) {
        firstWeekday = _knownOffsetForJan2013;
        
        for (int i = 2013; i <= _selectedYear+yearOffset; i++) {
            
            //account for leap year
            if (i%4 == 0
                && [[_daysInMonth objectAtIndex:1] integerValue] != 29) {
                [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
            }
            else if ([[_daysInMonth objectAtIndex:1] integerValue] != 28){
                [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
            }
            
            if (i == _selectedYear+yearOffset) {
                for (int j = 0; j < _selectedMonth+monthOffset-1; j++) {
                    firstWeekday += [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            else {
                for (int j = 0; j < 12; j++) {
                    firstWeekday += [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            
            //The first weekday should be on the first week of the month.
            firstWeekday = firstWeekday % 7;
        }
    }
    else {
        firstWeekday = _knownOffsetForJan2013;
        
        for (int i = 2013-1; i >= _selectedYear+yearOffset; i--) {
            
            //account for leap year
            if (i%4 == 0
                && (int)[_daysInMonth objectAtIndex:1] != 29) {
                [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
            }
            else if ((int)[_daysInMonth objectAtIndex:1] != 28){
                [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
            }
            
            if (i == _selectedYear+yearOffset) {
                for (int j = 11; j >= _selectedMonth+monthOffset-1; j--) {
                    firstWeekday -= [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            else {
                for (int j = 11; j >= 0; j--) {
                    firstWeekday -= [[_daysInMonth objectAtIndex:j] integerValue] % 7;
                }
            }
            
            //The first weekday should be on the first week of the month.
            firstWeekday = (firstWeekday % 7)+7;
        }
    }
    
    if (arrayId == 0)
    {
        [self setFirstWeekDay0:firstWeekday];
    }
    else if (arrayId == 1)
    {
        [self setFirstWeekDay1:firstWeekday];
    }
    else if (arrayId == 2)
    {
        [self setFirstWeekDay2:firstWeekday];
    }
    
    //Set the leap year stuff back up since we could have changed it beforehand.
    if ((_selectedYear+yearOffset)%4 == 0
        && (int)[_daysInMonth objectAtIndex:1] != 29) {
        [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
    }
    else if ((int)[_daysInMonth objectAtIndex:1] != 28){
        [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
    }
    //This should loop through the amounts of days in the given month.
    //  So change this to work with the month/year that the user has selected.
    for (int i=0; i < [[_daysInMonth objectAtIndex:_selectedMonth+monthOffset-1] integerValue]; i++) {
        [_calendarEvents[arrayId] addObject:[[NSMutableArray alloc] init]];
    }
}

//Takes in events from the json retrieved from the Google Calendar API.
//@param day Day the event is on, 1-31.
-(void)AppendEvent:(NSInteger)day :(NSDictionary *)eventDict :(int)arrayId {
    [[_calendarEvents[arrayId] objectAtIndex:day-1] addObject:eventDict];
}

//@param day Day the events are on, 1-31.
-(NSArray *)getEventsForDay:(NSInteger)day {
    return [_calendarEvents[1] objectAtIndex:day-1];
}

//@return An integer in [0,6] that represents a day of the week.
-(int)getFirstWeekDay:(int)arrayId {
    int firstWeekDay = -1;
    if (arrayId == 0)
    {
        firstWeekDay = _firstWeekDay0;
    }
    else if (arrayId == 1)
    {
        firstWeekDay = _firstWeekDay1;
    }
    else if (arrayId == 2)
    {
        firstWeekDay = _firstWeekDay2;
    }
    return firstWeekDay;
}

//Gets a string that represents the current month.
-(NSString *)getMonthBarDate {
    NSString *month;
    switch (_selectedMonth) {
        case 1:
            month = @"January";
            break;
        case 2:
            month = @"February";
            break;
        case 3:
            month = @"March";
            break;
        case 4:
            month = @"April";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"August";
            break;
        case 9:
            month = @"September";
            break;
        case 10:
            month = @"October";
            break;
        case 11:
            month = @"November";
            break;
        case 12:
            month = @"December";
            break;
    }
    
    return month;
}

//@return Should be an integer in [28,31].
-(int)getDaysOfMonth {
    //_selectedMonth contains [1,12], daysInMonth takes in [0,11]
    return (int)[[_daysInMonth objectAtIndex:_selectedMonth-1] integerValue];
}

//@param month An integer in [1,12]
//@param year An integer that represents the exact year. No offsets here...
//@return Should be an integer in [28,31].
-(int)getDaysOfMonth:(int)month :(int)year {
    int daysOfMonth = 0;
    //Account for leap year when dealing with February.
    if (year%4 == 0
        && month == 2) {
        daysOfMonth = 29;
    }
    else {
        daysOfMonth = (int)[[_daysInMonth objectAtIndex:month-1] integerValue];
    }
    return daysOfMonth;
}

-(NSInteger)getCurrentDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components day];
}

-(NSInteger)getCurrentMonth
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components month];
}

-(NSInteger)getCurrentYear
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components year];
}

-(NSArray *)getEventsStartingToday
{
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    
    int startAt = 0;
    
    for(int i = 1; i <= 1; i++) {
        // if at current month set the day to start pulling starting at index current day - 1
        if(i == 1) {
            startAt = (int)[self getCurrentDay] - 1;
        
        } else {
            startAt = 0;
        }
        int monthLength = (int)[_calendarEvents[i] count];
        for(int j = startAt; j < monthLength; j++) {
            [allEvents addObjectsFromArray:[self eventSorter:[_calendarEvents[i] objectAtIndex:j]]];
        }
    }
    
    return allEvents;
}

-(NSArray *)getEventsForCurrentMonth:(NSInteger) offset
{
//clayton merge
    NSMutableArray *allEvents = [[NSMutableArray alloc] init];
    int monthLength = (int)[_calendarEvents[1] count];
        for(int j = 0; j < monthLength; j++) {
            [allEvents addObjectsFromArray:[self eventSorter:[_calendarEvents[1] objectAtIndex:j]]];
        }
    
    
    return allEvents;
}

- (NSMutableArray *)eventSorter:(NSArray *)unsorted
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    [newArray addObjectsFromArray:unsorted];
    

        
    Preferences *preferences = [Preferences getSharedInstance];
    
    int currentPos = 0;
    
    while (currentPos < [newArray count])
    {
        NSString *categoryName = [newArray[currentPos] objectForKey:@"category"];
        BOOL removedSomething = NO;
        for (NSString *name in [[MonthlyEvents getSharedInstance] getCategoryNames])
        {
            if ([categoryName isEqualToString:name] && ([preferences getPreference:categoryName] == NO))
            {
                [newArray removeObjectAtIndex:currentPos];
                
                removedSomething = YES;
            }
        }
        
        if(!removedSomething)
        {
            currentPos++;
        }
    }
    
    if ([newArray count] > 1)
    {
        int currentPos = 0;
        
        BOOL finished = FALSE;
        
        while(!finished)
        {
            int lowestItem = currentPos;
            
            for (int i = currentPos + 1; i < [newArray count]; i++)
            {
                NSRange startHr1 = NSMakeRange(11, 2);
                NSRange startMn1 = NSMakeRange(14, 2);
                NSString *startHrStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr1];
                NSString *startMnStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn1];
                NSString *startTime1 =[startHrStr1 stringByAppendingString:startMnStr1];
                int start1 = [startTime1 intValue];
                
                
                NSRange startHr2 = NSMakeRange(11, 2);
                NSRange startMn2 = NSMakeRange(14, 2);
                NSString *startHrStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                NSString *startMnStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                int start2 = [startTime2 intValue];
                
                
                if (start1 > start2)
                {
                    lowestItem = i;
                }
                else if (start1 == start2)
                {
                    NSRange endHr1 = NSMakeRange(11, 2);
                    NSRange endMn1 = NSMakeRange(14, 2);
                    NSString *endHrStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr1];
                    NSString *endMnStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn1];
                    NSString *endTime1 =[endHrStr1 stringByAppendingString:endMnStr1];
                    int end1 = [endTime1 intValue];
                    
                    
                    NSRange endHr2 = NSMakeRange(11, 2);
                    NSRange endMn2 = NSMakeRange(14, 2);
                    NSString *endHrStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr2];
                    NSString *endMnStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn2];
                    NSString *endTime2 =[endHrStr2 stringByAppendingString:endMnStr2];
                    int end2 = [endTime2 intValue];
                    
                    
                    if (end1 > end2)
                    {
                        lowestItem = i;
                    }
                }
                
                
            }
            
            if (lowestItem != currentPos)
            {
                NSDictionary *temp = newArray[currentPos];
                
                newArray[currentPos] = newArray[lowestItem];
                
                newArray[lowestItem] = temp;
                
                currentPos += 1;
            }
            else
            {
                currentPos += 1;
            }
            
            if (currentPos == [newArray count] - 1)
            {
                finished = TRUE;
                
            }
        }
    }
    return newArray;
}

//@return Should be an integer in [28,31].
-(int)getDaysOfPreviousMonth {
    int previousMonth = 0;
    if (_selectedMonth-2 < 0) {
        previousMonth=12+_selectedMonth-2;
    }
    else {
        previousMonth = _selectedMonth-2;
    }
    //previousMonth contains [0,11] daysInMonth takes in [0,11]
    return (int)[[_daysInMonth objectAtIndex:previousMonth] integerValue];
}

-(void)offsetMonth:(int)offset {
    if (_selectedMonth + offset <= 0) {
        [self setMonth:_selectedMonth+offset+12];
        [self setYear:_selectedYear-1];
        
        //account for leap year
        if (_selectedYear%4 == 0
            && (int)[_daysInMonth objectAtIndex:1] != 29) {
            [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
        }
        else if ((int)[_daysInMonth objectAtIndex:1] != 28){
            [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
        }
    }
    else if (_selectedMonth + offset > 12) {
        [self setMonth:_selectedMonth+offset-12];
        [self setYear:_selectedYear+1];
        
        //account for leap year
        if (_selectedYear%4 == 0
            && (int)[_daysInMonth objectAtIndex:1] != 29) {
            [_daysInMonth replaceObjectAtIndex:1 withObject:@29];
        }
        else if ((int)[_daysInMonth objectAtIndex:1] != 28){
            [_daysInMonth replaceObjectAtIndex:1 withObject:@28];
        }
    }
    else {
        [self setMonth:_selectedMonth+offset];
    }
    
    
    //[self resetEvents];
    
    MonthlyEvents *auth = [MonthlyEvents getSharedInstance];
    
    if (offset == 1)
    {
        _calendarEvents[0] = _calendarEvents[1];
        _firstWeekDay0 = _firstWeekDay1;
        _calendarEvents[1] = _calendarEvents[2];
        _firstWeekDay1 = _firstWeekDay2;
        _calendarEvents[2] = [NSNull null];
        
        _jsonReceivedDicts[0] = _jsonReceivedDicts[1];
        _jsonReceivedDicts[1] = _jsonReceivedDicts[2];
        
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
        for (int j=0; j<[[auth getCategoryNames] count]; j++)
        {
            [jsonDict setObject:@0 forKey:[auth getCategoryNames][j]];
        }
        _jsonReceivedDicts[2] = jsonDict;
    }
    else if (offset == -1)
    {
        _calendarEvents[2] = _calendarEvents[1];
        _firstWeekDay2 = _firstWeekDay1;
        _calendarEvents[1] = _calendarEvents[0];
        _firstWeekDay1 = _firstWeekDay0;
        _calendarEvents[0] = [NSNull null];
        
        _jsonReceivedDicts[2] = _jsonReceivedDicts[1];
        _jsonReceivedDicts[1] = _jsonReceivedDicts[0];
        
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
        for (int j=0; j<[[auth getCategoryNames] count]; j++)
        {
            [jsonDict setObject:@0 forKey:[auth getCategoryNames][j]];
        }
        _jsonReceivedDicts[0] = jsonDict;
    }
    else if (offset > 1 || offset < -1)
    {
        [self resetEvents];
    }
}


//@param day Accepts integers in [1,31]
-(void)setSelectedDay:(int)day {
    [self setDay:day];
}

//@return Returns an integer in [1,31]
-(int)getSelectedDay {
    return _selectedDay;
}

//@return Returns an integer in [1,12]
-(int)getSelectedMonth {
    return _selectedMonth;
}

//@return The exact year, no off by one here.
-(int)getSelectedYear {
    return _selectedYear;
}

-(BOOL)doesMonthNeedLoaded:(int) arrayId
{
    BOOL shouldLoad = NO;
    //Check if the month is in memory and if the has been there for less than 5 minutes.
    if ([_calendarEvents[arrayId] isEqual:[NSNull null]])
    {
        shouldLoad = YES;
    }
    return shouldLoad;
}

-(BOOL)isMonthDoneLoading:(int)arrayId
{
    BOOL doneLoading = YES;
    for (id key in _jsonReceivedDicts[arrayId])
    {
        if ([_jsonReceivedDicts[arrayId][key] intValue] == 0)
        {
            doneLoading = NO;
            break;
        }
    }
    return doneLoading;
}

-(void)setCalendarJsonReceivedForMonth:(int)arrayId :(NSString*)calendar
{
    _jsonReceivedDicts[arrayId][calendar] = @1;
}

-(BOOL)getCalendarJsonReceivedForMonth:(int)arrayId :(NSString*)calendar
{
    BOOL jsonReceived = [_jsonReceivedDicts[arrayId][calendar] boolValue];

    return jsonReceived;
}

@end
