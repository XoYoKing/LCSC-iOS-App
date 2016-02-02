//
//  CalendarInfo.m
//  LCSC
//
//  Created by Student on 1/27/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import "CalendarInfo.h"

@interface CalendarInfo()
@end

@implementation CalendarInfo

static NSMutableArray *daysInMonth;
static NSDictionary *calendarIds;
static NSArray *categoryNames;

//@param month An integer in [1,12]
//@param year An integer that represents the exact year. No offsets here...
//@return Should be an integer in [28,31].
+(int)getDaysOfMonth:(int)month :(int)year {
    //account for leap year.
    
    if(!daysInMonth || [daysInMonth count] == 0) {
        daysInMonth = [[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]];
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

+(NSArray *)getDaysOfAllMonthsInYear:(int)year
{
    NSMutableArray *daysOfMonths;
    if(!daysInMonth || [daysInMonth count] == 0) {
        daysInMonth = [[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]];
    }
    (void)[daysOfMonths initWithArray:daysInMonth copyItems:YES];
    
    // account for leap year
    if(year % 4 == 0) {
        daysOfMonths[1] = @29;
    }
    
    return daysOfMonths;
}

+(NSArray *)getCategoryNames
{
    if(!categoryNames || [categoryNames count] == 0)
    {
        categoryNames = [[NSMutableArray alloc] initWithArray:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Rec"]];
    }
    return [[NSArray alloc] initWithArray:categoryNames copyItems:YES];
}

+(NSString *)getCalIdOfCategory:(NSString *)category
{
    if(!calendarIds || [calendarIds count] == 0)
    {
        calendarIds = [[NSDictionary alloc]
                       initWithObjectsAndKeys:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com", @"Academics",
                       @"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com", @"Student Activities",
                       @"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com", @"Warrior Athletics",
                       @"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com", @"Entertainment",
                       @"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com", @"Residence Life",
                       @"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com", @"Campus Rec", nil];
    }
    
    return calendarIds[category];
}

+(NSDictionary *)getCalIds
{
    if(!calendarIds || [calendarIds count] == 0)
    {
        calendarIds = [[NSDictionary alloc]
                       initWithObjectsAndKeys:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com", @"Academics",
                       @"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com", @"Student Activities",
                       @"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com", @"Warrior Athletics",
                       @"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com", @"Entertainment",
                       @"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com", @"Residence Life",
                       @"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com", @"Campus Rec", nil];
    }
    
    return [[NSDictionary alloc] initWithDictionary:calendarIds copyItems:YES];
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
