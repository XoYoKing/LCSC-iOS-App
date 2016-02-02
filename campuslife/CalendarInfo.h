//
//  CalendarInfo.h
//  LCSC
//
//  Created by Student on 1/27/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarInfo : NSObject
+(int)getDaysOfMonth:(int)month :(int)year;
+(NSArray *)getDaysOfAllMonthsInYear:(int)year;

// Methods for getting the information on category names and Calendar Ids
+(NSArray *)getCategoryNames;
+(NSString *)getCalIdOfCategory:(NSString *)category;
+(NSDictionary *)getCalIds;

// These are for covenvience
+(NSInteger)getCurrentDay;
+(NSInteger)getCurrentMonth;
+(NSInteger)getCurrentYear;

+(NSString *)getMonthBarDateOfMonth:(NSInteger)selectedMonth;
@end
