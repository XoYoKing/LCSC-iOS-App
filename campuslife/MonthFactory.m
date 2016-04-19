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
    NSString *indexStr = [MonthFactory getIndexStr:month :year];
    MonthOfEvents *thisMonth;
    thisMonth = (MonthOfEvents *)[monthCache objectForKey:indexStr];
    return  thisMonth != nil;
}

+(void) insertIntoCache:(NSArray *)events forMonth:(NSInteger)month andYear:(NSInteger)year
{
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
    while(pullMonthStart < pullMonthStop && pullYearStart <= pullYearStop) {
        if(![MonthFactory checkCacheForMonth:pullMonthStart andYear:pullYearStart]) {
            break;
        }
        [CalendarInfo incrementMonth:&pullMonthStart :&pullYearStart];
    }
    
    // Now search for the month and year we need to stop pulling from
    while(pullMonthStop > pullMonthStart && pullYearStop >= pullYearStart) {
        if(![MonthFactory checkCacheForMonth:pullMonthStop andYear:pullYearStop]) {
            break;
        }
        [CalendarInfo decrementMonth:&pullMonthStop :&pullYearStop];
    }
    NSMutableArray *events;
    if(pullMonthStart < pullMonthStop && pullYearStart <= pullYearStop) {
        // pull needed data from google calendars
        events = (NSMutableArray *)[MonthFactory loadEventsFromMonth:
                                  pullMonthStart andYear:pullYearStart
                                    toMonth:pullMonthStop andYear:pullYearStop];
    }

    // put the data into the cache
    NSInteger curMonth = startMonth;
    NSInteger curYear = startYear;
    NSInteger curIndex = 0;
    
    // This loop iterates over the long list of events we just generated and inserts them in the cache if that month
    // needs updated
    while(curMonth <= endMonth && curYear <= endYear && curIndex < [events count]) {
        MonthOfEvents *newMonth;
        NSString *indexStr = [MonthFactory getIndexStr:curMonth :curYear];
        
        if(![MonthFactory checkCacheForMonth:curMonth andYear:curYear]) {
            NSMutableArray *monthEvents = [[NSMutableArray alloc] init];
            while(curIndex < [events count]) {
                LCSCEvent *curEvent = (LCSCEvent *)[events objectAtIndex:curIndex];
                NSInteger eventStartMonth = [curEvent getStartMonth];
                if(eventStartMonth == curMonth) {
                    [monthEvents addObject:curEvent];
                    
                } else if(eventStartMonth > curMonth){
                    break;
                }
                curIndex++;
            }

            newMonth = [[MonthOfEvents alloc] initWithMonth:curMonth andYear:curYear andEventsArray:monthEvents];
            [monthCache setObject:newMonth forKey:[MonthFactory getIndexStr:curMonth :curYear]];
        }
        else {
            newMonth = [monthCache objectForKey:indexStr];
        }
        
        if(newMonth != nil) {
            //[monthsOfEvents addObject:newMonth];
        }
        [CalendarInfo incrementMonth:&curMonth :&curYear];
    }
    
    while(curMonth <= endMonth && curYear <= endYear) {
        NSString *indexStr = [MonthFactory getIndexStr:curMonth :curYear];
        MonthOfEvents *emptyMonth = [[MonthOfEvents alloc]
                                     initWithMonth:curMonth andYear:curYear
                                     andEventsArray:@[]];
        if(![MonthFactory checkCacheForMonth:curMonth andYear:curYear]) {
            [monthCache setObject:emptyMonth forKey:indexStr];
        }
        [CalendarInfo incrementMonth:&curMonth :&curYear];
    }
    
    NSInteger month_i = startMonth;
    NSInteger year_i = startYear;
    while(month_i <= endMonth && year_i <= endYear) {
        NSString *indexStr = [MonthFactory getIndexStr:month_i :year_i];
        MonthOfEvents *whatever = [monthCache objectForKey:indexStr];
        [CalendarInfo incrementMonth:&month_i :&year_i];
        if(whatever != nil) {
            [monthsOfEvents addObject:whatever];
        }
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
    NSString *startMonthAsString;
    NSString *endMonthAsString;
    
    if(startDay < 10) {
        curDayAsString = [NSString stringWithFormat:@"0%d", startDay];
        
    } else {
        curDayAsString = [NSString stringWithFormat:@"%d", startDay];
    }
    
    if(startMonth < 10) {
        startMonthAsString = [NSString stringWithFormat:@"0%ld", (long)startMonth];
    } else {
        startMonthAsString = [NSString stringWithFormat:@"%ld", (long)startMonth];
    }
    
    if(endMonth < 10) {
        endMonthAsString = [NSString stringWithFormat:@"0%ld", (long)endMonth];
    } else {
        endMonthAsString = [NSString stringWithFormat:@"%ld", (long)endMonth];
    }
    
    for (NSString *name in [CalendarInfo getCategoryNames])
    {
        NSURL *url;
        NSString *calendarID = [CalendarInfo getCalIdOfCategory:name];
        NSString *urlString;
        
        urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%ld-%@-%@T00:00:00-07:00&timeMax=%ld-%@-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",
                     calendarID, (long)startYear, startMonthAsString, curDayAsString, (long)endYear, endMonthAsString, endDay];
        
        // take this out of the loop
        url = [NSURL URLWithString:urlString];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil)
        {
            [events addObjectsFromArray:[self parseJSON:data :endMonth :endYear]];
        }
    }
    
    [events sortUsingComparator: ^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2];
    }];
    return events;
}


+(NSArray *) getReocurrencesOfEvent:(LCSCEvent *)event
{
    NSMutableArray *reoccurrences = [[NSMutableArray alloc] init];
    NSInteger curDay = [event getStartDay];
    NSInteger today = curDay;
    NSInteger curMonth = [event getStartMonth];
    NSInteger thisMonth = curMonth;
    NSInteger curYear = [event getStartYear];
    NSInteger thisYear = curYear;
    BOOL done = NO;
    NSString *eventSummary = [[event getSummary]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    while([MonthFactory checkCacheForMonth:curMonth andYear:curYear] && !done) {
        NSString *indexStr = [MonthFactory getIndexStr:curMonth :curYear];
        MonthOfEvents *curEventMonth = [monthCache objectForKey:indexStr];

        for(; curDay <= [curEventMonth daysInMonth]; curDay++) {
            NSArray *day = [curEventMonth getEventsForDay:curDay];
            BOOL eventInDay = NO;
            for(LCSCEvent *otherEvent in day) {
                NSString *otherSummary = [[otherEvent getSummary]
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([eventSummary isEqualToString:otherSummary]) {
                    [reoccurrences addObject:otherEvent];
                    eventInDay = YES;
                }
            }

            if(!eventInDay) {
                done = YES;
                break;
            }
        }
        [CalendarInfo incrementMonth:&curMonth :&curYear];
        curDay = 1;
    }
    done = NO;
    while([MonthFactory checkCacheForMonth:thisMonth andYear:thisYear] && !done) {
        NSString *indexStr = [MonthFactory getIndexStr:thisMonth :thisYear];
        MonthOfEvents *curEventMonth = [monthCache objectForKey:indexStr];
        
        for(; today >= 1; today--) {
            NSArray *day = [curEventMonth getEventsForDay:today];
            BOOL eventInDay = NO;
            for(LCSCEvent *otherEvent in day) {
                NSString *otherSummary = [[otherEvent getSummary]
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([eventSummary isEqualToString:otherSummary]) {
                    [reoccurrences addObject:otherEvent];
                    eventInDay = YES;
                }
            }
            
            if(!eventInDay) {
                done = YES;
                break;
            }
        }
        [CalendarInfo decrementMonth:&thisMonth :&thisYear];
        if (thisMonth == 1 || thisMonth == 3 || thisMonth == 5 || thisMonth == 7 || thisMonth == 8 || thisMonth == 10 || thisMonth == 12) {
            today = 31;
        }
        if (thisMonth == 2) {
            today = 28;
        }
        else{
            today = 30;
        }
    }

    return reoccurrences;
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
        
        for (int i=0; i<oldEventsInfo.count; i++)
        {
            //These will store the information that's needed for the event.
            NSString *startTime;
            NSString *endTime;
            //NSString *recur;
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
                else if ([[oldEventsInfo[i] objectForKey:@"status"] isEqualToString:@"cancelled"])
                {
                    continue;
                }
                else
                {
                    continue;
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
            else
            {
                continue;
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
            
            event = [[NSDictionary alloc] initWithObjects:@[category, location, summary, start, end, description] forKeys:@[@"category", @"location", @"summary", @"start", @"end", @"description"]];
            
            [parsedEvents addObject:[[LCSCEvent alloc] initWithNSDictionary:event]];
        }
    }
    
    return parsedEvents;
}


@end