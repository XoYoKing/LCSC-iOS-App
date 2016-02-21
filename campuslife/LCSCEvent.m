//
//  LCSCEvent.m
//  LCSC
//
//  Created by Computer Science on 2/12/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "LCSCEvent.h"

@implementation LCSCEvent
-(id)initWithNSDictionary:(NSDictionary *)dict
{
    if(([[dict objectForKey:@"start"] objectForKey:@"dateTime"] == nil)) {
        _allDay = YES;
        _startTimestamp = [[dict objectForKey:@"start"] objectForKey:@"date"];
        _endTimestamp = [[dict objectForKey:@"end"] objectForKey:@"date"];
        
    } else {
        _allDay = NO;
        _startTimestamp = [[dict objectForKey:@"start"] objectForKey:@"dateTime"];
        _endTimestamp = [[dict objectForKey:@"end"] objectForKey:@"dateTime"];
    }
    
    _startDay = [[_startTimestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
    _startMonth = [[_startTimestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
    _startYear = [[_startTimestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
    _endDay = [[_endTimestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
    _endMonth = [[_endTimestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
    _endYear = [[_endTimestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
    
    _eventDescription = [dict objectForKey:@"description"];
    _location = [dict objectForKey:@"location"];
    _category = [dict objectForKey:@"category"];
    _summary = [dict objectForKey:@"summary"];
    
    return self;
}

// TODO: Needs to compare down to hours and minutes
-(NSComparisonResult)compare:(LCSCEvent *)otherEvent;
{
    NSComparisonResult comp;
    NSInteger event1Year = [self getStartYear];
    NSInteger event1Month = [self getStartMonth];
    NSInteger event1Day = [self getStartDay];
    NSInteger event1Hour = 0;
    
    NSInteger event2Year = [otherEvent getStartYear];
    NSInteger event2Month = [otherEvent getStartYear];
    NSInteger event2Day = [otherEvent getStartYear];
    NSInteger event2Hour = 0;
    
    if(event1Year < event2Year) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Year > event2Year) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Month < event2Month) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Month > event2Month) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Day < event2Day) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Day > event2Day) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Hour < event2Hour) {
        comp = (NSComparisonResult )NSOrderedAscending;
        
    } else if(event1Hour > event2Hour) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else {
        comp = (NSComparisonResult )NSOrderedSame;
    }
    
    return comp;
}
@end
