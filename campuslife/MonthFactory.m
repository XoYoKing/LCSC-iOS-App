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
#import "DataManager.h"
#import "JsonParser.h"

@implementation MonthFactory

+(NSString *)getIndexStr:(NSInteger)month :(NSInteger)year
{
    return [NSString stringWithFormat:@"%ld-%ld", (long)year, (long)month];
}

+(BOOL) checkCacheForMonth:(NSInteger)month andYear:(NSInteger)year
{
    NSString *indexStr = [MonthFactory getIndexStr:month :year];
    MonthOfEvents *thisMonth;
    NSMutableDictionary *monthCache = [[DataManager singletonDataManager] getCache];
    thisMonth = (MonthOfEvents *)[monthCache objectForKey:indexStr];
    return  thisMonth != nil;
}

+(MonthOfEvents *) getMonthOfEventsFromMonth:(NSInteger)month andYear:(NSInteger)year
{
    NSMutableDictionary *monthCache = [[DataManager singletonDataManager] getCache];
    NSString *searchStr = [MonthFactory getIndexStr:month :year];
    MonthOfEvents *thisMonth;
    if([MonthFactory checkCacheForMonth:month andYear:year]) {
        thisMonth = (MonthOfEvents *)[monthCache objectForKey:searchStr];
    } else {
        NSArray *events = [JsonParser loadEventsFromMonth:month andYear:year toMonth:month andYear:year];
        thisMonth = [[MonthOfEvents alloc] initWithMonth:month andYear:year andEventsArray:events];
        [monthCache setObject:thisMonth forKey:searchStr];
    }
    return thisMonth;
}

+(NSArray *) getMonthOfEventsFromMonth:(NSInteger)startMonth andYear:(NSInteger) startYear
                               toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableDictionary *monthCache = [[DataManager singletonDataManager] getCache];
    NSMutableArray *monthsOfEvents = [[NSMutableArray alloc] init];
    NSInteger month_i = startMonth;
    NSInteger year_i = startYear;
    while(month_i <= endMonth && year_i <= endYear) {
        NSString *indexStr = [MonthFactory getIndexStr:month_i :year_i];
        MonthOfEvents *whatever = [monthCache objectForKey:indexStr];
        [CalendarInfo incrementMonth:&month_i :&year_i];
        if(whatever != nil)
            [monthsOfEvents addObject:whatever];
    }
    return monthsOfEvents;
}

//Will be removing, here for testing only
+(NSArray *) getMonthOfEventsFromMonth2:(NSInteger)startMonth andYear:(NSInteger) startYear
                                      toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableDictionary* monthCache = [[DataManager singletonDataManager] getCache];
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
        events = (NSMutableArray *)[JsonParser loadEventsFromMonth:
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

+(NSArray *) getReocurrencesOfEvent:(LCSCEvent *)event
{
    NSMutableDictionary* monthCache = [[DataManager singletonDataManager] getCache];
    NSMutableArray *reoccurrences = [[NSMutableArray alloc] init];
    NSMutableArray *backReoccurrences = [[NSMutableArray alloc]init];
    NSMutableArray *finalReoccurrences = [[NSMutableArray alloc]init];
    NSInteger curDay = [event getStartDay];
    NSInteger today = curDay - 1;
    NSInteger curMonth = [event getStartMonth];
    NSInteger thisMonth = curMonth;
    NSInteger curYear = [event getStartYear];
    NSInteger thisYear = curYear;
    BOOL done = NO;
    NSString *eventSummary = [[event getSummary]
                              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    eventSummary = [eventSummary uppercaseString];
    while([MonthFactory checkCacheForMonth:curMonth andYear:curYear] && !done) {
        NSString *indexStr = [MonthFactory getIndexStr:curMonth :curYear];
        MonthOfEvents *curEventMonth = [monthCache objectForKey:indexStr];

        for(; curDay <= [curEventMonth daysInMonth]; curDay++) {
            NSArray *day = [curEventMonth getEventsForDay:curDay];
            BOOL eventInDay = NO;
            for(LCSCEvent *otherEvent in day) {
                NSString *otherSummary = [[otherEvent getSummary]
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                otherSummary = [otherSummary uppercaseString];
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
                otherSummary = [otherSummary uppercaseString];
                if([eventSummary isEqualToString:otherSummary]) {
                    [backReoccurrences addObject:otherEvent];
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
    
    return [reoccurrences arrayByAddingObjectsFromArray:backReoccurrences];

    //return reoccurrences;
}
@end