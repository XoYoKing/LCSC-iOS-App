//
//  MonthFactory.h
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthOfEvents.h"

@interface MonthFactory : NSObject

/** Manufactures and returns a MonthOfEvents object for events in the month and year
  * specified by date
  */
+(MonthOfEvents *) getMonthOfEventsFromDate:(NSDate *) date;

/** Manufactures and returns MonthOfEvents objects for events in the months and years
  * specified by the date range
  */
+(NSMutableArray *) getMonthOfEventsFromDate:(NSDate *)from_date toDate:(NSDate *) to_date;

@end