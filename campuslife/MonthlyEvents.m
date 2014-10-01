//
//  MonthlyEvents.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "MonthlyEvents.h"
#import "Authentication.h"
#import "XMLReader.h"

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
        
        //NSLog(@"This month is: %d", month);
        
        //account for leap year.
        if (year % 4 == 0) {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @29, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        else {
            [sharedInstance setDaysInMonth:[[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]]];
        }
        
        [sharedInstance setKnownOffsetForJan2013:2];
        
        [sharedInstance setCategoryNames:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Rec"]];
        
        [sharedInstance setCalendarEvents:[[NSMutableArray alloc]initWithArray:@[[NSNull null], [NSNull null], [NSNull null]]]];
        
        // Remove before deployment!
        // Josh NOTE
        /*
        // URL for the XML of events on the Academic calendar.
        NSURL *urlAca = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/0rn5mgclnhc7htmh0ht0cc5pgk%40group.calendar.google.com/public/full?alt=json"];
        
        // URL for the XML of events on the Campus Rec calendar.
        NSURL *urlRec = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/h4j413d3q0uftb2crk0t92jjlc%40group.calendar.google.com/public/full?alt=json"];
        
        // URL for the XML of events on the Entertainment calendar.
        NSURL *urlEnt = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/m6h2d5afcjfnmaj8qr7o96q89c%40group.calendar.google.com/public/full?alt=json"];
        
        // URL for the XML of events on the Residence Life calendar.
        NSURL *urlRes = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/gqv0n6j15pppdh0t8adgc1n1ts%40group.calendar.google.com/public/full?alt=json"];
        
        // URL for the XML of events on the Student Activities calendar.
        NSURL *urlAct = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/l9qpkh5gb7dhjqv8nm0mn098fk%40group.calendar.google.com/public/full?alt=json"];
        
        // URL for the XML of events on the Warrior Athletics calendar.
        NSURL *urlAth = [NSURL URLWithString:@"https://www.google.com/calendar/feeds/d6jbgjhudph2mpef1cguhn4g9g%40group.calendar.google.com/public/full?alt=json"];
        */
        /*
        // Parse events on the Academic calendar into the NSDictionary.
        NSError *errorAca = nil;
        NSData *dataAca = [NSData dataWithContentsOfURL:urlAca];
        NSDictionary *eventsInfoDictAca = [XMLReader dictionaryForXMLData:dataAca options:XMLReaderOptionsProcessNamespaces error:&errorAca];
        
        // Parse events on the Campus Rec calendar into the NSDictionary.
        NSError *errorRec = nil;
        NSData *dataRec = [NSData dataWithContentsOfURL:urlRec];
        NSDictionary *eventsInfoDictRec = [XMLReader dictionaryForXMLData:dataRec options:XMLReaderOptionsProcessNamespaces error:&errorRec];
        
        // Parse events on the Entertainment calendar into the NSDictionary.
        NSError *errorEnt = nil;
        NSData *dataEnt = [NSData dataWithContentsOfURL:urlEnt];
        NSDictionary *eventsInfoDictEnt = [XMLReader dictionaryForXMLData:dataEnt options:XMLReaderOptionsProcessNamespaces error:&errorEnt];
        
        // Parse events on the Residence Life calendar into the NSDictionary.
        NSError *errorRes = nil;
        NSData *dataRes = [NSData dataWithContentsOfURL:urlRes];
        NSDictionary *eventsInfoDictRes = [XMLReader dictionaryForXMLData:dataRes options:XMLReaderOptionsProcessNamespaces error:&errorRes];
        
        // Parse events on the Student Activities calendar into the NSDictionary.
        NSError *errorAct = nil;
        NSData *dataAct = [NSData dataWithContentsOfURL:urlAct];
        NSDictionary *eventsInfoDictAct = [XMLReader dictionaryForXMLData:dataAct options:XMLReaderOptionsProcessNamespaces error:&errorAct];
        
        // Parse events on the Warrior Athletics calendar into the NSDictionary.
        NSError *errorAth = nil;
        NSData *dataAth = [NSData dataWithContentsOfURL:urlAth];
        NSDictionary *eventsInfoDictAth = [XMLReader dictionaryForXMLData:dataAth options:XMLReaderOptionsProcessNamespaces error:&errorAth];
         
        NSLog(@"%@",eventsInfoDictAca);
        
        
        NSMutableArray *arrayOfXMLDict = [[NSMutableArray alloc] init];
        [arrayOfXMLDict addObject:eventsInfoDictAth];
        [arrayOfXMLDict addObject:eventsInfoDictAct];
        [arrayOfXMLDict addObject:eventsInfoDictRes];
        [arrayOfXMLDict addObject:eventsInfoDictEnt];
        [arrayOfXMLDict addObject:eventsInfoDictRec];
        [arrayOfXMLDict addObject:eventsInfoDictAca];
        */

        /*
        NSMutableArray *jsonsReceived = [[NSMutableArray alloc] init];
        NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
        for (int i=0; i<3; i++)
        {
            for (NSString *name in [sharedInstance getCategoryNames]) {
                jsonDict[name] = @0;
            }
            [jsonsReceived addObject:jsonDict];
        }
        
        //[sharedInstance setJsonReceivedDicts:jsonsReceived];
        */
        
        NSMutableArray *jsonsReceived = [[NSMutableArray alloc] init];
        
        //Authentication *auth = [Authentication getSharedInstance];
        
        for (int i=0; i<3; i++)
        {
            NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
            for (int j=0; j<[[sharedInstance getCategoryNames] count]; j++)
            {
                [jsonDict setObject:@0 forKey:[sharedInstance getCategoryNames][j]];
            }
            [jsonsReceived addObject:jsonDict];
        }
        NSLog(@"Got Here1");
        [sharedInstance setJsonReceivedDicts:jsonsReceived];
        NSLog(@"Got Here2");
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
    
    //NSLog(@"The array of daysInMonth is %@", _daysInMonth);
    
    //NSLog(@"The first weekday index is %d", _firstWeekDay);
    
    //NSLog(@"The selectedMonth is %d", _selectedMonth);
    
    //NSLog(@"The number of days for the given month is:%ld", [[_daysInMonth objectAtIndex:_selectedMonth-1] integerValue]);
    
    //This should loop through the amounts of days in the given month.
    //  So change this to work with the month/year that the user has selected.
    for (int i=0; i < [[_daysInMonth objectAtIndex:_selectedMonth+monthOffset-1] integerValue]; i++) {
        [_calendarEvents[arrayId] addObject:[[NSMutableArray alloc] init]];
    }
}

//Takes in events from the json retrieved from the Google Calendar API.
//@param day Day the event is on, 1-31.
-(void)AppendEvent:(NSInteger)day :(NSDictionary *)eventDict :(int)arrayId {
    NSLog(@"------------day------------");
    NSLog(@"%li",(long)day);
    NSLog(@"-----------event-------------");
    NSLog(@"%@",eventDict);
    NSLog(@"-----------array-------------");
    NSLog(@"%i",arrayId);
    NSLog(@"------------------------");
    
    //[[_calendarEvents[arrayId] objectAtIndex:day-1] addObject:eventDict];
    //NSLog(@"%@",[_calendarEvents description]);
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
    
    //NSLog(@"The new year is %d and the new month is %d", _selectedYear, _selectedMonth);
    
    //[self resetEvents];
    
    Authentication *auth = [Authentication getSharedInstance];
    
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
    /*
    if ([_jsonReceivedDicts[arrayId][calendar] intValue] == 1)
    {
        NSLog(@"Month: %d already loaded the %@ calendar",arrayId, calendar);
    }
    else
    {
        NSLog(@"Month: %d has had %@ calendar loaded",arrayId, calendar);
    }*/
    _jsonReceivedDicts[arrayId][calendar] = @1;
}

-(BOOL)getCalendarJsonReceivedForMonth:(int)arrayId :(NSString*)calendar
{
    BOOL jsonReceived = [_jsonReceivedDicts[arrayId][calendar] boolValue];

    return jsonReceived;
}

@end
