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
+(NSArray *)getDaysOfAllMonths:(int)year;
+(NSInteger)getCurrentDay;
+(NSInteger)getCurrentMonth;
+(NSInteger)getCurrentYear;
@end
