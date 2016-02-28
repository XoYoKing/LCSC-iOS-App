//
//  MonthFactory.m
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

// TODO: Integrate the setJsonDictsReceived thing from MonthlyEvents into this

#import "MonthFactory.h"
#import "CalendarInfo.h"
#import "MonthOfEvents.h"
#import "LCSCEvent.h"

@implementation MonthFactory

static NSMutableDictionary *monthCache;

+(void)initialize
{
    monthCache = [[NSMutableDictionary alloc] init];
}


+(NSString *)getIndexStr:(NSInteger)month :(NSInteger)year
{
    return [NSString stringWithFormat:@"%ld-%ld", (long)year, (long)month];
}


+(BOOL) checkCacheForMonth:(NSInteger)month andYear:(NSInteger)year
{
    return ([monthCache objectForKey:[MonthFactory getIndexStr:month :year]] != nil);
}


+(MonthOfEvents *) getMonthOfEventsFromMonth:(NSInteger)month andYear:(NSInteger)year
{
    NSString *searchStr = [MonthFactory getIndexStr:month :year];
    MonthOfEvents *thisMonth;
    
    if([MonthFactory checkCacheForMonth:month andYear:year]) {
        thisMonth = (MonthOfEvents *)[monthCache objectForKey:searchStr];
    
    } else {
        NSArray *events = [MonthFactory loadEventsFromMonth:month andYear:year toMonth:month andYear:year];
        thisMonth = [[MonthOfEvents alloc] initWithMonth:month andYear:year andEventsArray:events];
        [monthCache setObject:thisMonth forKey:searchStr];
    }
    
    return thisMonth;
}


+(NSArray *) getMonthOfEventsFromMonth:(NSInteger)startMonth andYear:(NSInteger) startYear
                                      toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableArray *monthsOfEvents = [[NSMutableArray alloc] init];
    NSInteger pullMonthStart = startMonth;
    NSInteger pullYearStart = startYear;
    NSInteger pullMonthStop = endMonth;
    NSInteger pullYearStop = endYear;
    
    // Search for the month and year we need to start the pull from
    while(pullMonthStart < pullMonthStop && pullYearStart < pullYearStop) {
        if(![MonthFactory checkCacheForMonth:pullMonthStart andYear:pullYearStart]) {
            break;
        }
        [CalendarInfo incrementMonth:&pullMonthStart :&pullYearStart];
    }
    
    // Now search for the month and year we need to stop pulling from
    while(pullMonthStop > pullMonthStart && pullYearStop > pullYearStart) {
        if(![MonthFactory checkCacheForMonth:pullMonthStop andYear:pullYearStop]) {
            break;
        }
        [CalendarInfo decrementMonth:&pullMonthStop :&pullYearStop];
    }
    
    // pull needed data from google calendars and put it in the cache
    NSMutableArray *events = (NSMutableArray *)[MonthFactory loadEventsFromMonth:
                              pullMonthStart andYear:pullYearStart
                                toMonth:pullMonthStop andYear:pullYearStop];
    
    [events sortUsingComparator: ^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    
    NSInteger curMonth = startMonth;
    NSInteger curYear = startYear;
    NSInteger curIndex = 0;
    while(curMonth <= endMonth && curYear <= endYear && curIndex < [events count]) {
        MonthOfEvents *newMonth;
        NSString *indexStr = [MonthFactory getIndexStr:curMonth :curYear];
        if(![MonthFactory checkCacheForMonth:curMonth andYear:curYear]) {
            NSMutableArray *monthEvents = [[NSMutableArray alloc] init];
            for(; curIndex < [events count]; curIndex++) {
                LCSCEvent *curEvent = (LCSCEvent *)[events objectAtIndex:curIndex];
                NSInteger eventStartMonth = [curEvent getStartMonth];
                if([curEvent getStartMonth] == curMonth) {
                    [monthEvents addObject:curEvent];
                    
                } else if([curEvent getStartMonth > curMonth]){
                    break;
                }
            }
            
            if([monthEvents count] > 0) {
                newMonth = [[MonthOfEvents alloc] initWithMonth:curMonth andYear:curYear andEventsArray:monthEvents];
                [monthCache setObject:newMonth forKey:[MonthFactory getIndexStr:curMonth :curYear]];
            }
        }
        else {
            newMonth = [monthCache objectForKey:indexStr];
        }
        
        if(newMonth != nil) {
            [monthsOfEvents addObject:newMonth];
        }
        [CalendarInfo incrementMonth:&curMonth :&curYear];
    }
    
    return monthsOfEvents;
}


+(NSArray *)loadEventsFromMonth:(NSInteger) startMonth andYear:(NSInteger)startYear toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableArray *events = [[NSMutableArray alloc] init];
    // the first day of the start month
    int startDay = 1;
    // the last day of the end month
    int endDay = [CalendarInfo getDaysOfMonth:(int)endMonth ofYear:(int)endYear];
    
    NSString *curDayAsString;
    if(startDay < 10) {
        curDayAsString = [NSString stringWithFormat:@"0%d", startDay];
        
    } else {
        curDayAsString = [NSString stringWithFormat:@"%d", startDay];
    }
    
    for (NSString *name in [CalendarInfo getCategoryNames])
    {
        NSURL *url;
        NSString *calendarID = [CalendarInfo getCalIdOfCategory:name];
        NSString *urlString;
        
        
        if(startMonth >= 10 && startMonth <= 12 && endMonth >= 10 && startMonth <= 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%ld-0%ld-%@T00:00:00-07:00&timeMax=%ld-0%ld-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID, (long)startYear,(long)startMonth, curDayAsString, (long)endYear, (long)endMonth, endDay];
            
        } else if(startMonth >= 10 && startMonth <= 12 && endMonth < 10 && startMonth > 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%ld-0%ld-%@T00:00:00-07:00&timeMax=%ld-%ld-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID, (long)startYear,(long)startMonth, curDayAsString, (long)endYear, (long)endMonth, endDay];
            
        } else if(startMonth < 10 && startMonth > 12 && endMonth >= 10 && startMonth <= 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%ld-%ld-0%@T00:00:00-07:00&timeMax=%ld-0%ld-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID, (long)startYear,(long)startMonth, curDayAsString, (long)endYear, (long)endMonth, endDay];
            
        } else {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%ld-%ld-%@T00:00:00-07:00&timeMax=%ld-%ld-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID, (long)startYear,(long)startMonth, curDayAsString, (long)endYear, (long)endMonth, endDay];
        }
        
        
        // take this out of the loop
        url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil)
        {
            [events addObjectsFromArray:[self parseJSON:data :endMonth :endYear]];
        }
    }
    
    return events;
}


+(NSMutableArray *)parseJSON:(NSData *)JSONAsData :(NSInteger)endMonth :(NSInteger)endYear
{
    NSMutableArray *parsedEvents = [[NSMutableArray alloc] init];
    NSError *error = nil;
    
    // Get the JSON data as a dictionary.
    
    NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:JSONAsData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        // This is the case that an error occured during converting JSON data to dictionary.
        // Simply log the error description.
        
    }
    else{
        //Get the events as an array
        
        NSMutableArray *oldEventsInfo = [eventsInfoDict valueForKeyPath:@"items"];
        
        //////////////////////////////////////////
        NSArray *holdDict = [oldEventsInfo copy];
        for (int i=0; i<holdDict.count; i++){
            NSString *startTStuff = [[NSString alloc] init];
            NSString *endTStuff = [[NSString alloc] init];
            NSString *currentEndTime = [[holdDict[i] objectForKey:@"end"] objectForKey:@"dateTime"];
            NSString *currentStartTime = [[holdDict[i] objectForKey:@"start"] objectForKey:@"dateTime"];
            if (currentEndTime != nil) {
                startTStuff = [currentStartTime substringWithRange:NSMakeRange(10, [currentStartTime length]-10)];
                endTStuff = [currentEndTime substringWithRange:NSMakeRange(10, [currentStartTime length]-10)];
                int EnddayHold = [[currentEndTime substringWithRange:NSMakeRange(8, 2)] intValue];
                int StartdayHold = [[currentStartTime substringWithRange:NSMakeRange(8, 2)] intValue];
                if (abs(EnddayHold-StartdayHold)>1){
                    int yearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                    int monthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                    int daysInMonth = [CalendarInfo getDaysOfMonth:monthHold ofYear:yearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){
                        int startyearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                        int startmonthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                        int amountOfStartDays = [CalendarInfo getDaysOfMonth:startmonthHold ofYear:startyearHold];
                        amountOfDays = amountOfStartDays-StartdayHold+EnddayHold;
                    }
                    int counter = 0;
                    NSDictionary *holdRecurEvent = holdDict[i];
                    int newDay = StartdayHold;
                    for (int j = 0; j<amountOfDays ; j++,counter++,newDay++){
                        NSMutableDictionary *replacementEvent = [holdRecurEvent mutableCopy];
                        if (newDay > daysInMonth){
                            monthHold++;
                            if (monthHold >12){
                                monthHold = 1;
                                yearHold++;
                                j--;
                            }
                            newDay = 1;
                            daysInMonth = [CalendarInfo getDaysOfMonth:monthHold ofYear:yearHold];
                        }
                        
                        NSString *SyearHold = [NSString stringWithFormat:@"%d",yearHold];
                        NSString *sMonthHold = [[NSString alloc] init ];
                        NSString *sDayHold = [[NSString alloc] init];
                        if (monthHold < 10){
                            sMonthHold = [NSString stringWithFormat:@"0%d",monthHold];
                        }else{
                            sMonthHold = [NSString stringWithFormat:@"%d",monthHold];
                        }
                        if (newDay < 10){
                            sDayHold = [NSString stringWithFormat:@"0%d",newDay];
                        }else{
                            sDayHold = [NSString stringWithFormat:@"%d",newDay];
                        }
                        NSString *newStartTime = [NSString stringWithFormat:@"%@-%@-%@%@",SyearHold,sMonthHold,sDayHold,startTStuff];
                        NSString *newEndDate = [NSString stringWithFormat:@"%@-%@-%@%@",SyearHold,sMonthHold,sDayHold,endTStuff];
                        NSMutableDictionary *holdDictStart = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *holdDictEnd = [[NSMutableDictionary alloc] init];
                        [holdDictStart setObject:newStartTime forKey:@"dateTime"];
                        [holdDictEnd setObject:newEndDate forKey:@"dateTime"];
                        [replacementEvent setObject:holdDictStart forKey:@"start"];
                        [replacementEvent setObject:holdDictEnd forKey:@"end"];
                        
                        if (counter == 0){
                            oldEventsInfo[i] = replacementEvent;
                        }
                        else{
                            //clayton spring break is broken in both code bases for all evetns and calendar
                            
                            [oldEventsInfo addObject: replacementEvent];
                            
                        }
                    }
                }
            }
            
            //fix for all day events
            currentStartTime = [[holdDict[i] objectForKey:@"start"] objectForKey:@"date"];
            currentEndTime = [[holdDict[i] objectForKey:@"end"] objectForKey:@"date"];
            if (currentEndTime != nil){
                int EnddayHold = [[currentEndTime substringWithRange:NSMakeRange(8, 2)] intValue];
                int StartdayHold = [[currentStartTime substringWithRange:NSMakeRange(8, 2)] intValue];
                
                if (abs(EnddayHold-StartdayHold)>1){
                    
                    int startyearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                    int startmonthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                    
                    int daysInMonth = [CalendarInfo getDaysOfMonth:startmonthHold ofYear:startyearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){
                        
                        int amountOfStartDays = [CalendarInfo getDaysOfMonth:startmonthHold ofYear:startyearHold];
                        amountOfDays = amountOfStartDays-StartdayHold+EnddayHold;
                    }
                    if (amountOfDays >1) {
                        int counter = 0;
                        NSDictionary *holdRecurEvent = holdDict[i];
                        int newDay = StartdayHold;
                        int newEndDay = newDay + 1;
                        int endMonthHold = startmonthHold;
                        int endYearHold = startyearHold;
                        int daysInEndMonth = [CalendarInfo getDaysOfMonth:endMonthHold ofYear:endYearHold];
                        for (int j = 0; j<amountOfDays-1 ; j++,counter++,newDay++,newEndDay++){
                            NSMutableDictionary *replacementEvent = [holdRecurEvent mutableCopy];
                            if (newDay > daysInMonth){
                                startmonthHold++;
                                if (startmonthHold >12){
                                    startmonthHold = 1;
                                    startyearHold++;
                                    j--;
                                }
                                newDay = 1;
                                daysInMonth = [CalendarInfo getDaysOfMonth:startmonthHold ofYear:startyearHold];
                            }
                            if(newEndDay > daysInEndMonth){
                                endMonthHold++;
                                if (endMonthHold > 12){
                                    endMonthHold = 1;
                                    endYearHold++;
                                }
                                newEndDay = 1;
                                daysInEndMonth = [CalendarInfo getDaysOfMonth:startmonthHold ofYear:startyearHold];
                                
                            }
                            NSString *SyearHold = [NSString stringWithFormat:@"%d",startyearHold];
                            NSString *sMonthHold = [[NSString alloc] init];
                            NSString *sDayHold = [[NSString alloc] init];
                            NSString *EyearHold = [NSString stringWithFormat:@"%d",endYearHold];
                            NSString *eMonthHold = [[NSString alloc] init];
                            NSString *eDayHold = [[NSString alloc] init];
                            if (startmonthHold < 10){
                                sMonthHold = [NSString stringWithFormat:@"0%d",startmonthHold];
                            }else{
                                sMonthHold = [NSString stringWithFormat:@"%d",startmonthHold];
                            }
                            if (newDay < 10){
                                sDayHold = [NSString stringWithFormat:@"0%d",newDay];
                            }else{
                                sDayHold = [NSString stringWithFormat:@"%d",newDay];
                            }
                            if (endMonthHold < 10){
                                eMonthHold = [NSString stringWithFormat:@"0%d",endMonthHold];
                            }else{
                                eMonthHold = [NSString stringWithFormat:@"%d",endMonthHold];
                            }
                            if (newEndDay < 10){
                                eDayHold = [NSString stringWithFormat:@"0%d",newEndDay];
                            }else{
                                eDayHold = [NSString stringWithFormat:@"%d",newEndDay];
                            }
                            NSString *newStartTime = [NSString stringWithFormat:@"%@-%@-%@",SyearHold,sMonthHold,sDayHold];
                            NSString *newEndDate = [NSString stringWithFormat:@"%@-%@-%@",EyearHold,eMonthHold,eDayHold];
                            NSMutableDictionary *holdDictStart = [[NSMutableDictionary alloc] init];
                            NSMutableDictionary *holdDictEnd = [[NSMutableDictionary alloc] init];
                            [holdDictStart setObject:newStartTime forKey:@"date"];
                            [holdDictEnd setObject:newEndDate forKey:@"date"];
                            [replacementEvent setObject:holdDictStart forKey:@"start"];
                            [replacementEvent setObject:holdDictEnd forKey:@"end"];
                            
                            if (counter == 0){
                                oldEventsInfo[i] = replacementEvent;
                            }
                            else{
                                [oldEventsInfo addObject: replacementEvent];
                                
                            }
                        }
                    }
                }
            }
        }
        //////////////////////////////////////////
        if (oldEventsInfo == nil) {
            oldEventsInfo = [[NSMutableArray alloc] init];
        }
        
        NSString *category;
        
        for (NSString *name in [CalendarInfo getCategoryNames])
        {
            //if ([CalendarInfo getIndexOfSubstringInString:name :[eventsInfoDict valueForKeyPath:@"summary"]] != -1) {
            if([name rangeOfString:[eventsInfoDict valueForKeyPath:@"summary"]].location != NSNotFound) {
                category = name;
                break;
            }
        }
        //Convert the structure of the dictionaries in eventsInfo so that the dictionaries are compatible with the rest
        //  of the app.
        
        NSMutableArray *eventsInfo = [[NSMutableArray alloc] init];
        for (int i=0; i<oldEventsInfo.count; i++)
        {
            //These will store the information that's needed for the event.
            NSString *startTime;
            NSString *endTime;
            //NSString *recur;
            NSArray *recurrence;
            NSString *location;
            NSString *summary;
            NSString *description;
            
            if ([oldEventsInfo[i] valueForKey:@"start"] != nil)
            {
                if ([oldEventsInfo[i] valueForKeyPath:@"start.dateTime"] != nil) {
                    if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSArray class]]) {
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"][0] valueForKey:@"dateTime"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"][0] valueForKey:@"dateTime"];
                    }
                    else if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSDictionary class]]){
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"] valueForKey:@"dateTime"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"] valueForKey:@"dateTime"];
                    }
                }else if ([oldEventsInfo[i] valueForKeyPath:@"start.date"] != nil){
                    if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSArray class]]) {
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"][0] valueForKey:@"date"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"][0] valueForKey:@"date"];
                    }
                    else if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSDictionary class]]){
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"] valueForKey:@"date"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"] valueForKey:@"date"];
                    }
                }
                
                
                
                
                
                if (endTime.length > 10){
                    NSString *endMoment = [endTime substringWithRange:NSMakeRange(10, 9)];
                    if ([endMoment isEqual: @"T00:00:00"]){
                        NSString *endDayPart = [NSString stringWithFormat:@"%d",[[endTime substringWithRange:NSMakeRange(8, 2)] intValue]-1];
                        if ([endDayPart intValue] >0){
                            if (endDayPart.length < 2){
                                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(9, 1) withString:endDayPart];
                            }else{
                                endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(8, 2) withString:endDayPart];
                            }
                            endTime = [endTime stringByReplacingOccurrencesOfString:@"T00:00:00" withString:@"T23:59:00"];
                            
                        }
                    }
                }
            }
            
            if (([oldEventsInfo[i] valueForKey:@"location"] != nil))
            {
                location = [oldEventsInfo[i] valueForKey:@"location"];
                
            }else{
                location = @"No Location Provided";
            }
            
            if ([oldEventsInfo[i] valueForKey:@"description"] != nil)
            {
                description = [oldEventsInfo[i] valueForKey:@"description"];
                
                
            }
            else{
                description = @"No Description Provided";
            }
            
            if ([oldEventsInfo[i] valueForKey:@"summary"] != nil)
            {
                summary = [oldEventsInfo[i] valueForKey:@"summary"];
                
            }
            
            //This will be the new dictionary for the current event.
            NSDictionary *event;
            NSDictionary *start;
            NSDictionary *end;
            //Is the event an all day event?
            if ([startTime length] < 12)
            {
                start = [[NSDictionary alloc] initWithObjects:@[startTime] forKeys:@[@"date"]];
                end = [[NSDictionary alloc] initWithObjects:@[endTime] forKeys:@[@"date"]];
            }
            else
            {
                start = [[NSDictionary alloc] initWithObjects:@[startTime] forKeys:@[@"dateTime"]];
                end = [[NSDictionary alloc] initWithObjects:@[endTime] forKeys:@[@"dateTime"]];
            }
            
            if (recurrence == nil)
            {
                event = [[NSDictionary alloc] initWithObjects:@[category, location, summary, start, end, description] forKeys:@[@"category", @"location", @"summary", @"start", @"end", @"description"]];
                
            }
            else
            {
                event = [[NSDictionary alloc] initWithObjects:@[category, location, summary, start, end, description, recurrence] forKeys:@[@"category", @"location", @"summary", @"start", @"end", @"description", @"recurrence"]];
            }
            
            //Puts the new event into the new array of event dictionaries!
            [eventsInfo addObject:event];
        }
        
        
        int selectedMonth = (int)endMonth;
        int selectedYear = (int)endYear;
        
        
        if (selectedMonth == 0)
        {
            selectedMonth = 12;
            selectedYear -= 1;
            
        }
        else if (selectedMonth == 13)
        {
            selectedMonth = 1;
            selectedYear += 1;
            
        }
        
        //Loop through the events
        for (int i=0; i<[eventsInfo count]; i++) {
            
            //Now we must parse the summary and alter the dictionary so that it can be
            //  used in the rest of the program easier. So we'll call parseSummaryForKey in this class
            //  to pull info out of the Summary field in the Dictionary and place
            //  it back into the dictionary mapped to a new key.
            
            NSMutableDictionary *currentEventInfo = [[NSMutableDictionary alloc] initWithDictionary:[eventsInfo objectAtIndex:i]];
            
            [currentEventInfo setObject:category forKey:@"category"];
            
            int startDay = 0;
            int startMonth = 0;
            int startYear = 0;
            
            int endDay = 0;
            
            //Determine if the event isn't an all day event type.
            if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"dateTime"] != nil) {
                startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                   objectForKey:@"dateTime"]
                                  substringWithRange:NSMakeRange(8, 2)]
                                 integerValue];
                
                startMonth = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue];
                
                startYear = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue];
                
                //The endDay must not be the day of the month that it is on, but the number of days from the first day
                //  of the startMonth.
                if (startYear == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                    for (int month=startMonth; month<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                        endDay += [CalendarInfo getDaysOfMonth:month ofYear:startYear];
                        
                    }
                    //Account for days in endMonth
                    endDay += [[[[currentEventInfo objectForKey:@"end"]
                                 objectForKey:@"dateTime"]
                                substringWithRange:NSMakeRange(8, 2)]
                               integerValue];
                }
                else {
                    //At the very beginning we'll be working with probably not a full year.
                    for (int month=startMonth; month<13; month++) {
                        endDay += [CalendarInfo getDaysOfMonth:month ofYear:startYear];
                        
                    }
                    
                    //Start by accounting for year differences.
                    for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                        int endMonth = 12;
                        //This makes sure that we stop on the month prior to the selected month
                        //  and then add in the days for that month.
                        if (year == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                            endMonth = [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                            //Account for days in endMonth
                            endDay += [[[[currentEventInfo objectForKey:@"end"]
                                         objectForKey:@"dateTime"]
                                        substringWithRange:NSMakeRange(8, 2)]
                                       integerValue];
                        }
                        
                        //This only takes into account full months strictly inbetween the start and end months.
                        for (int month=1; month<endMonth+1; month++) {
                            endDay += [CalendarInfo getDaysOfMonth:month ofYear:year];
                            
                        }
                    }
                }
            }
            
            else if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"date"] != nil) {
                startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                   objectForKey:@"date"]
                                  substringWithRange:NSMakeRange(8, 2)]
                                 integerValue];
                
                startMonth = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue];
                
                startYear = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue];
                
                //The endDay must not be the day of the month that it is on, but the number of days from the first day
                //  of the startMonth.
                if (startYear == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                    for (int month=startMonth; month<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                        endDay += [CalendarInfo getDaysOfMonth:month ofYear:startYear];
                        
                    }
                    //Account for days in endMonth
                    endDay += [[[[currentEventInfo objectForKey:@"end"]
                                 objectForKey:@"date"]
                                substringWithRange:NSMakeRange(8, 2)]
                               integerValue];
                }
                else {
                    //At the very beginning we'll be working with probably not a full year.
                    for (int month=startMonth; month<13; month++) {
                        endDay += [CalendarInfo getDaysOfMonth:month ofYear:startYear];
                        
                    }
                    
                    //Start by accounting for year differences.
                    for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                        int endMonth = 12;
                        //This makes sure that we stop on the month prior to the selected month
                        //  and then add in the days for that month.
                        if (year == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                            endMonth = [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                            //Account for days in endMonth
                            endDay += [[[[currentEventInfo objectForKey:@"end"]
                                         objectForKey:@"date"]
                                        substringWithRange:NSMakeRange(8, 2)]
                                       integerValue];
                        }
                        //This only takes into account full months strictly inbetween the start and end months.
                        for (int month=1; month<endMonth+1; month++) {
                            
                            endDay += [CalendarInfo getDaysOfMonth:month ofYear:year];
                            
                            
                        }
                    }
                }
                //This makes the end day exclusive! As per the google calendar's standard.
                endDay -= 1;
            }
            else if ([[currentEventInfo objectForKey:@"status"] isEqualToString:@"cancelled"])
            {
                continue;
            }
            else
            {
                continue;
            }
            
            float freq = 1.0;
            int repeat = 1;
            
            //If an event is reocurring, then we must account for that.
            
            
            //This will hold the number of days into the next month.
            int wrappedDays = endDay-[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
            
            
            
            //The e variable isn't being set properly. So fix it!
            
            int s = 0;
            int e = 0;
            
            //The outer loop loops through the reocurrences.
            for (int rep=0; rep<repeat; rep++) {
                BOOL iterateOverDays = YES;
                
                //Are we dealing with a monthly repeat?
                if (freq >= 28 && freq <= 31) {
                    freq = [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                    
                }
                else if (freq >= 365 && freq <= 366) {
                    if (startYear % 4 == 0) {
                        freq = 366;
                    }
                    else {
                        freq = 365;
                    }
                }
                
                
                //Here we setup the s and e variables for the for loop.
                if (startYear == selectedYear) {
                    //The startMonth is with respect to the startDay. The endDay quite possible
                    //  can be going into the next month.
                    if (startMonth == selectedMonth) {
                        s = startDay;
                        
                        //Check if the endDay will be moving into the next month.
                        if (endDay > [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear]) {
                            
                            e = [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                            
                        }
                        else {
                            e = endDay;
                        }
                    }
                    //Check if the startMonth is the previous month and the endDay will roll over into the next month.
                    else if (startMonth + 1 == selectedMonth && endDay > [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear]) {
                        
                        //We don't care about the days in the previous month, only that
                        //  the rolled over days are going to be in the selected month.
                        s = 1;
                        
                        //endDay is for sure going to be above the daysInMonth.
                        e = endDay%[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                        
                    }
                    else {
                        //We'll skip this iterating, because we won't add anything.
                        iterateOverDays = NO;
                    }
                }
                else if (startYear == selectedYear-1
                         && startMonth == 12
                         && endDay > [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear]) {
                    
                    //We don't care about the days in the previous month, only that
                    //  the rolled over days are going to be in the selected month.
                    s = 1;
                    
                    //endDay is for sure going to be above the daysInMonth.
                    e = endDay%[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                    
                }
                else {
                    //We'll skip this iterating, because we won't add anything.
                    iterateOverDays = NO;
                }
                if (iterateOverDays) {
                    //Add events for the startday all the way up to the end day.
                    for (int day=s; day<e+1; day++) {
                        if (day != 0) {
                            
                        }
                    }
                }
                
                //Setup the start and end vars for the next repeat.
                startDay = startDay + freq;
                
                endDay = endDay + freq;
                
                BOOL nextDateUpdated = NO;
                
                while (!nextDateUpdated)
                {
                    //Check if we're moving into a new month.
                    if (startDay%[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear] < startDay) {
                        
                        //Then we mod the startDay to get the day of the next month it will be on.
                        startDay = startDay-[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                        
                        endDay = endDay-[CalendarInfo getDaysOfMonth:startMonth ofYear:startYear];
                        
                        startMonth += 1;
                        
                        //Check to see if we transitioned to a new year.
                        if (startMonth > 12) {
                            startMonth = 1;
                            startYear += 1;
                        }
                        if (wrappedDays > 0) {
                            if (startMonth != 1) {
                                endDay += [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear] - [CalendarInfo getDaysOfMonth:startMonth-1 ofYear:startYear];
                                
                            }
                            else {
                                endDay += [CalendarInfo getDaysOfMonth:startMonth ofYear:startYear] - [CalendarInfo getDaysOfMonth:12 ofYear:startYear-1];
                                
                            }
                        }
                    }
                    else
                    {
                        nextDateUpdated = YES;
                    }
                }
            }
            
            [parsedEvents addObject:[[LCSCEvent alloc] initWithNSDictionary:currentEventInfo]];
        }
    }
    
    return parsedEvents;
}


@end