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

+(void)initialize
{
    daysInMonth = [[NSMutableArray alloc] initWithArray:@[@31, @28, @31, @30, @31, @30, @31, @31, @30, @31, @30, @31]];
    
    categoryNames = [[NSMutableArray alloc] initWithArray:@[@"Entertainment", @"Academics", @"Student Activities", @"Residence Life", @"Warrior Athletics", @"Campus Rec"]];
    
    calendarIds = [[NSDictionary alloc]
                   initWithObjectsAndKeys:@"0rn5mgclnhc7htmh0ht0cc5pgk@group.calendar.google.com", @"Academics",
                   @"l9qpkh5gb7dhjqv8nm0mn098fk@group.calendar.google.com", @"Student Activities",
                   @"d6jbgjhudph2mpef1cguhn4g9g@group.calendar.google.com", @"Warrior Athletics",
                   @"m6h2d5afcjfnmaj8qr7o96q89c@group.calendar.google.com", @"Entertainment",
                   @"gqv0n6j15pppdh0t8adgc1n1ts@group.calendar.google.com", @"Residence Life",
                   @"h4j413d3q0uftb2crk0t92jjlc@group.calendar.google.com", @"Campus Rec", nil];
}


//@param month An integer in [1,12]
//@param year An integer that represents the exact year. No offsets here...
//@return Should be an integer in [28,31].
+(int)getDaysOfMonth:(int)month ofYear:(int)year
{
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


+(int)getDaysOfPreviousMonth:(int)month ofYear:(int)year
{
    NSInteger lastMonth = month;
    NSInteger lastYear = year;
    [CalendarInfo decrementMonth:&lastMonth :&lastYear];
    return [CalendarInfo getDaysOfMonth:(int)lastMonth ofYear:(int)lastYear];
}


+(NSArray *)getDaysOfAllMonthsInYear:(int)year
{
    NSMutableArray *daysOfMonths;
    (void)[daysOfMonths initWithArray:daysInMonth copyItems:YES];
    
    // account for leap year
    if(year % 4 == 0) {
        daysOfMonths[1] = @29;
    }
    
    return daysOfMonths;
}


+(NSArray *)getCategoryNames
{
    return [[NSArray alloc] initWithArray:categoryNames copyItems:YES];
}


+(NSString *)getCalIdOfCategory:(NSString *)category
{
    return calendarIds[category];
}


+(NSDictionary *)getCalIds
{
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


+(NSInteger)getWeekdayOfMonth:(NSInteger)month andDay:(NSInteger)day andYear:(NSInteger)year
{
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setDay:day];
    [dateComps setMonth:month];
    [dateComps setYear:year];
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [gregorian dateFromComponents:dateComps];
    NSDateComponents *weekdayComponents =
    [gregorian components:NSWeekdayCalendarUnit fromDate:date];
    return [weekdayComponents weekday]-1;
}


+(NSInteger)getFirstWeekdayOfMonth:(NSInteger)month andYear:(NSInteger)year
{
    return [CalendarInfo getWeekdayOfMonth:month andDay:1 andYear:year];
}


+(NSInteger)getLastWeekdayOfMonth:(NSInteger)month andYear:(NSInteger)year
{
    return [CalendarInfo getWeekdayOfMonth:month
                                    andDay:[CalendarInfo getDaysOfMonth:month ofYear:year]
                                   andYear:year];
}


+(void) incrementMonth:(NSInteger *)month :(NSInteger *)year
{
    if(*month >= 12) {
        *month = 1;
        *year += 1;
    } else {
        *month += 1;
    }
}


+(void) decrementMonth:(NSInteger *)month :(NSInteger *)year
{
    if(*month <= 1) {
        *month = 12;
        *year -= 1;
    } else {
        *month -= 1;
    }
}


//Gets a string that represents the current month.
+(NSString *)getMonthBarDateOfMonth:(NSInteger)selectedMonth {
    NSString *month;
    switch (selectedMonth) {
        case 1:
            month = @"January";
            break;
        case 2:
            month = @"February";
            break;
        case 3:
            month = @"March";
            break;
        case 4:
            month = @"April";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"August";
            break;
        case 9:
            month = @"September";
            break;
        case 10:
            month = @"October";
            break;
        case 11:
            month = @"November";
            break;
        case 12:
            month = @"December";
            break;
    }
    
    return month;
}

@end
