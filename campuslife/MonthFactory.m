//
//  MonthFactory.m
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "MonthFactory.h"
#import "CalendarInfo.h"

@implementation MonthFactory
+(MonthOfEvents *) getMonthOfEventsFromMonth:(NSInteger)month andYear:(NSInteger)year
{
    NSArray *events = [MonthFactory loadEventsFromMonth:month andYear:year toMonth:month andYear:year];
    return [[MonthOfEvents alloc] initWithMonth:month andYear:year andEventsArray:events];
}

+(NSArray *)loadEventsFromMonth:(NSInteger) startMonth andYear:(NSInteger)startYear toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableArray *events;
    // the first day of the start month
    int startDay = 1;
    // the last day of the end month
    int endDay = [CalendarInfo getDaysOfMonth:endMonth ofYear:endYear];
    
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
        
        
        
        url = [NSURL URLWithString:urlString];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil)
        {
            //[self parseJSON:data];
        }
    }
    
    return events;
}


@end