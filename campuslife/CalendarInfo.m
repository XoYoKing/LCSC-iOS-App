//
//  CalendarInfo.m
//  LCSC
//
//  Created by Student on 1/27/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "CalendarInfo.h"

@interface CalendarInfo()
    @property (nonatomic, setter=setDaysInMonth:) NSMutableArray *daysInMonth;
@end

@implementation CalendarInfo

static NSArray *daysInMonth;

//@param month An integer in [1,12]
//@param year An integer that represents the exact year. No offsets here...
//@return Should be an integer in [28,31].
+(int)getDaysOfMonth:(int)month :(int)year {
    //account for leap year.
    
    if(!daysInMonth || [daysInMonth count] == 0) {
        (void)[daysInMonth initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]];
    }
    int daysOfMonth = 0;
    //Account for leap year when dealing with February.
    if (year%4 == 0
        && month == 2) {
        daysOfMonth = 29;
    }
    else {
        daysOfMonth = (int)[[daysInMonth objectAtIndex:month-1] integerValue];
    }
    return daysOfMonth;
}

+(NSArray *)getDaysOfAllMonths:(int)year
{
    NSMutableArray *daysOfMonths;
    if(!daysInMonth || [daysInMonth count] == 0) {
        (void)[daysInMonth initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]];
    }
    (void)[daysOfMonths initWithArray:daysInMonth copyItems:YES];
    
    // account for leap year
    if(year % 4 == 0) {
        daysOfMonths[1] = @29;
    }
    
    return daysOfMonths;
}

+(NSInteger)getCurrentDay
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components day];
}

+(NSInteger)getCurrentMonth
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components month];
}

+(NSInteger)getCurrentYear
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    return [components year];
}

@end
