//
//  MonthFactory.h
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthOfEvents.h"
#import "LCSCEvent.h"

@interface MonthFactory : NSObject

/** Manufactures and returns a MonthOfEvents object for events in the month and year
  * specified by date
  */
+(MonthOfEvents *) getMonthOfEventsFromMonth:(NSInteger)month andYear:(NSInteger)year;

/** Manufactures and returns MonthOfEvents objects for events in the months and years
  * specified by the date range
  */
+(NSArray *) getMonthOfEventsFromMonth:(NSInteger)startMonth andYear:(NSInteger) startYear
                                      toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear;

+(NSArray *) getReocurrencesOfEvent:(LCSCEvent *)event;

@end