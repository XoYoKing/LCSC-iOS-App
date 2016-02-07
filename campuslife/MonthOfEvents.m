//
//  MonthOfEvents.m
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "MonthOfEvents.h"
#import "CalendarInfo.h"
#import "EventHelper.h"

@interface MonthOfEvents ()
    @property (atomic, strong) NSMutableArray *days;
@end

@implementation MonthOfEvents
-(id)initWithMonth:(NSInteger)month andYear:(NSInteger) year andEventsArray:(NSArray *)events
{
    int number_of_days = [CalendarInfo getDaysOfMonth:(int)month ofYear:(int)year];
    
    // Initialize the days array to contain several arrays for each day
    _days = [[NSMutableArray alloc] init];
    for(int i = 0; i < number_of_days; ++i) {
        [_days addObject:[[NSMutableArray alloc] init]];
    }
    
    _month = month;
    _year = year;
    
    [self loadEventsFromArray:events];
    
    return self;
}

-(NSArray *)getEventsForDay:(NSInteger)day
{
    return (NSArray *)[_days objectAtIndex:day-1];
}

/** Adds event event to day of the month
  * Should probably keep these in order based upon time in the future
  */
-(void)addEvent:(NSDictionary *)event toDay:(NSInteger)day
{
    NSMutableArray *dayArray = [_days objectAtIndex:day-1];
    [dayArray addObject:event];
}

-(void)loadEventsFromArray:(NSArray *)events
{
    NSInteger eventStartDay, eventStartMonth, eventStartYear;
    for(NSDictionary *event in events) {
        eventStartDay = [EventHelper getEventStartDay:event];
        eventStartMonth = [EventHelper getEventStartMonth:event];
        eventStartYear  = [EventHelper getEventStartYear:event];
        
        // check that the event actually occurs in this month and year before adding it
        if(eventStartMonth == _month && eventStartYear == _year) {
            [self addEvent:event toDay:eventStartDay];
        }
    }
}

@end
