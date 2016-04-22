//
//  MonthOfEvents.h
//  LCSC
//
//  Created by Computer Science on 2/1/16.
//  Copyright (c) 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "LCSCEvent.h"

@interface MonthOfEvents : NSObject <NSFastEnumeration,NSCoding>
-(NSArray *)getEventsForDay:(NSInteger)day;
-(id)initWithMonth:(NSInteger)month andYear:(NSInteger) year andEventsArray:(NSArray *)events;
-(NSInteger)daysInMonth;
-(void)addEvent:(LCSCEvent *)event toDay:(NSInteger)day;
-(id)initWithoutEvents:(NSInteger)month andYear:(NSInteger)year; 
@property (nonatomic, readonly, getter=getMonth) NSInteger month;
@property (nonatomic, readonly, getter=getYear) NSInteger year;
@end
