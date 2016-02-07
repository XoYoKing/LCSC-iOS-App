//
//  EventHelper.h
//  LCSC
//
//  Created by Computer Science on 2/7/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

// A Helper class for accessing the event data from the extremely ugly NSDictionary event structure
// The events should eventually be made into a class of their own that has these methods, but for now this should suffice

#import <Foundation/Foundation.h>

@interface EventHelper : NSObject
+(BOOL)isAllDayEvent:(NSDictionary *)event;

+(NSInteger)getEventStartDay:(NSDictionary *)event;
+(NSInteger)getEventStartMonth:(NSDictionary *)event;
+(NSInteger)getEventStartYear:(NSDictionary *)event;
+(NSString *)getEventStartTimestamp:(NSDictionary *)event;

+(NSInteger)getEventEndDay:(NSDictionary *)event;
+(NSInteger)getEventEndMonth:(NSDictionary *)event;
+(NSInteger)getEventEndYear:(NSDictionary *)event;
+(NSString *)getEventEndTimestamp:(NSDictionary *)event;

+(NSString *)getEventCategory:(NSDictionary *)event;
+(NSString *)getEventDescription:(NSDictionary *)event;
+(NSString *)getEventSummary:(NSDictionary *)event;
+(NSString *)getEventLocation:(NSDictionary *)event;

+(void)sortEventsInArray:(NSMutableArray *)eventsArray;


@end
