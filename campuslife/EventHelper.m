//
//  EventHelper.m
//  LCSC
//
//  Created by Computer Science on 2/7/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "EventHelper.h"

@implementation EventHelper
+(BOOL)isAllDayEvent:(NSDictionary *)event
{
    return ([[event objectForKey:@"start"] objectForKey:@"dateTime"] == nil);
}


// Method for getting event start date and time information
+(NSInteger)getEventStartDay:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventStartTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
}

+(NSInteger)getEventStartMonth:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventStartTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
}

+(NSInteger)getEventStartYear:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventStartTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
}

+(NSString *)getEventStartTimestamp:(NSDictionary *)event
{
    NSString *timestamp = @"";
    if([EventHelper isAllDayEvent:event]) {
        timestamp = [[event objectForKey:@"start"] objectForKey:@"date"];
    }
    
    else {
        timestamp = [[event objectForKey:@"start"] objectForKey:@"dateTime"];
    }
    return timestamp;
}


// Method for getting event end date and time information
+(NSInteger)getEventEndDay:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventEndTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
}

+(NSInteger)getEventEndMonth:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventEndTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
}

+(NSInteger)getEventEndYear:(NSDictionary *)event
{
    NSString *timestamp = [EventHelper getEventEndTimestamp:event];
    return [[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
}

+(NSString *)getEventEndTimestamp:(NSDictionary *)event
{
    NSString *timestamp = @"";
    if([EventHelper isAllDayEvent:event]) {
        timestamp = [[event objectForKey:@"end"] objectForKey:@"date"];
    }
    
    else {
        timestamp = [[event objectForKey:@"end"] objectForKey:@"dateTime"];
    }
    return timestamp;
}

// These methods allow us to get other important information about the events
+(NSString *)getEventCategory:(NSDictionary *)event
{
    return [event objectForKey:@"category"];
}

+(NSString *)getEventDescription:(NSDictionary *)event
{
    return [event objectForKey:@"description"];
}

+(NSString *)getEventSummary:(NSDictionary *)event
{
    return [event objectForKey:@"summary"];
}

+(NSString *)getEventLocation:(NSDictionary *)event
{
    return [event objectForKey:@"location"];
}

// Comparison function for sortEventsInArray
+(NSComparisonResult)compareEvents:(NSMutableDictionary *)event1 :(NSMutableDictionary *)event2
{
    NSComparisonResult comp;
    NSInteger event1Year = [EventHelper getEventStartYear:event1];
    NSInteger event1Month = [EventHelper getEventStartMonth:event1];
    NSInteger event1Day = [EventHelper getEventStartDay:event1];
    NSInteger event1Hour = 0;
    
    NSInteger event2Year = [EventHelper getEventStartYear:event2];
    NSInteger event2Month = [EventHelper getEventStartMonth:event2];
    NSInteger event2Day = [EventHelper getEventStartDay:event2];
    NSInteger event2Hour = 0;
    
    if(event1Year < event2Year) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Year > event2Year) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Month < event2Month) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Month > event2Month) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Day < event2Day) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Day > event2Day) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Hour < event2Hour) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Hour > event2Hour) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else {
        comp = (NSComparisonResult )NSOrderedSame;
    }
    
    return comp;
}

+(void)sortEventsInArray:(NSMutableArray *)eventsArray
{
    [eventsArray sortUsingComparator: ^NSComparisonResult(id obj1, id obj2){
        return [self compareEvents:obj1 :obj2];
    }];
}
@end
