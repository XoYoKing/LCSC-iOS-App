//
//  MonthOfEvents.m
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "MonthOfEvents.h"
#import "CalendarInfo.h"
#import "LCSCEvent.h"

@interface MonthOfEvents ()
    @property (atomic, strong) NSMutableArray *days;
@end

@implementation MonthOfEvents

-(id)initWithCoder:(NSCoder *)coder
{
    if(self = [super init])
    {
        _days = [coder decodeObjectForKey:@"_days"];
        _month = [coder decodeIntForKey:@"_month"];
        _year = [coder decodeIntForKey:@"_year"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_days forKey:@"_days"];
    [encoder encodeInt:(int)_month forKey:@"_month"];
    [encoder encodeInt:(int)_year forKey:@"_year"];
}

-(id)initWithoutEvents:(NSInteger)month andYear:(NSInteger)year
{
    int number_of_days = [CalendarInfo getDaysOfMonth:(int)month ofYear:(int)year];
    _days = [[NSMutableArray alloc] init];
    for(int i = 0; i < number_of_days; ++i) {
        [_days addObject:[[NSMutableArray alloc] init]];
    }
    _month = month;
    _year = year;
    return self;
}

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


-(NSInteger)daysInMonth
{
    return [_days count];
}


-(NSArray *)getEventsForDay:(NSInteger)day
{
    return (NSArray *)[_days objectAtIndex:day-1];
}

/** Adds event event to day of the month
  * Should probably keep these in order based upon time in the future
  */
-(void)addEvent:(LCSCEvent *)event toDay:(NSInteger)day
{
    NSMutableArray *dayArray = [_days objectAtIndex:day-1];
    [dayArray addObject:event];
}

-(void)loadEventsFromArray:(NSArray *)events
{
    NSInteger eventStartDay, eventStartMonth, eventStartYear;
    for(LCSCEvent *event in events) {
        eventStartDay = [event getStartDay];
        eventStartMonth = [event getStartMonth];
        eventStartYear  = [event getStartYear];
        
        // check that the event actually occurs in this month and year before adding it
        if(eventStartMonth == _month && eventStartYear == _year) {
            [self addEvent:event toDay:eventStartDay];
        }
    }
}

- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState *) enumerationState
                                   objects: (id __unsafe_unretained []) stackBuffer
                                     count: (NSUInteger) length
{
    return [_days countByEnumeratingWithState:enumerationState
                                      objects:stackBuffer
                                        count:length];
}


@end
