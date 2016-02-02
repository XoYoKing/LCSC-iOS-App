//
//  MonthOfEvents.m
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "MonthOfEvents.h"
#import "CalendarInfo.h"

@interface MonthOfEvents ()
    @property (atomic, strong) NSMutableArray *days;
@end

@implementation MonthOfEvents
-(id)initWithMonth:(NSInteger)month andYear:(NSInteger) year
{
    int number_of_days = [CalendarInfo getDaysOfMonth:(int)month ofYear:(int)year];
    _days = [[NSMutableArray alloc] initWithCapacity:number_of_days];
    _month = month;
    _year = year;
    
    return self;
}

-(NSDictionary *)getEventOnDay:(int)day
{
    return (NSDictionary *)[_days objectAtIndex:day-1];
}
@end
