//
//  MonthlyEvents.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MonthlyEvents : NSObject


+(MonthlyEvents *)getSharedInstance;
+(MonthlyEvents *) getAllEventsInstance;

-(void)resetEvents;
-(void)refreshArrayOfEvents:(int)arrayId;
-(void)AppendEvent:(NSInteger)day :(NSDictionary *)eventDict :(int)arrayId;
-(NSArray *)getEventsForDay:(NSInteger)day;
-(NSArray *)getEventsStartingToday;
-(NSArray *)getEventsForCurrentMonth:(NSInteger) offset;
-(int)getFirstWeekDay:(int)arrayId ;
-(NSString *)getMonthBarDate;
-(int)getDaysOfMonth;
-(int)getDaysOfMonth:(int)month :(int)year;
-(int)getDaysOfPreviousMonth;
-(void)offsetMonth:(int)offset;

-(void)setSelectedDay:(int)day;
-(int)getSelectedDay;
-(NSInteger)getCurrentDay;
-(NSInteger)getCurrentMonth;
-(NSInteger)getCurrentYear;
-(int)getSelectedMonth;
-(int)getSelectedYear;

-(BOOL)doesMonthNeedLoaded:(int)arrayId;
-(BOOL)isMonthDoneLoading:(int)arrayId;

-(void)setCalendarJsonReceivedForMonth:(int)arrayId :(NSString*)calendar;
-(BOOL)getCalendarJsonReceivedForMonth:(int)arrayId :(NSString*)calendar;

@property (nonatomic, setter=setYear:) int selectedYear;
@property (nonatomic, setter=setMonth:) int selectedMonth;
@property (nonatomic, strong, setter=setCategoryNames:, getter=getCategoryNames) NSArray *categoryNames;
@property (nonatomic, getter=getUserCanManageEvents, setter=setUserCanManageEvents:) BOOL userCanManageEvents;
@property (nonatomic, strong, setter=setCalIds:, getter=getCalIds) NSDictionary *calendarIds;
@property (nonatomic, strong, setter=setEventIds:, getter=getEventIds) NSDictionary *authorizationEventIds;
@property (nonatomic, strong, setter=setAuthCals:, getter=getAuthCals) NSMutableDictionary *authorizedCalendars;


@end
