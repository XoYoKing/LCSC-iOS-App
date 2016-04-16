//
//  LCSCEvent.m
//  LCSC
//
//  Created by Computer Science on 2/12/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "LCSCEvent.h"

@implementation LCSCEvent
-(void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeBool:_allDay forKey:@"_allDay"];
    [coder encodeObject:_startTimestamp forKey:@"_startTimestamp"];
    [coder encodeObject:_endTimestamp forKey:@"_endTimestamp"];
    [coder encodeInteger:_startDay forKey:@"_startDay"];
    [coder encodeInteger:_startMonth forKey:@"_startMonth"];
    [coder encodeInteger:_startYear forKey:@"_startYear"];
    [coder encodeInteger:_endDay forKey:@"_endDay"];
    [coder encodeInteger:_endYear forKey:@"_endYear"];
    [coder encodeObject:_eventDescription forKey:@"_eventDescription"];
    [coder encodeObject:_location forKey:@"_location"];
    [coder encodeObject:_category forKey:@"_category"];
    [coder encodeObject:_summary forKey:@"_summary"];
}
-(id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self!=NULL)
    {
        _allDay = [coder decodeObjectForKey:@"_allDay"];
        _startTimestamp = [coder decodeObjectForKey:@"_startTimestamp"];
        _endTimestamp = [coder decodeObjectForKey:@"_endTimestamp"];
        _startDay = (NSInteger)[coder decodeObjectForKey:@"_startDay"];
        _startMonth = (NSInteger)[coder decodeObjectForKey:@"_startMonth"];
        _startYear = (NSInteger)[coder decodeObjectForKey:@"_startYear"];
        _endDay = (NSInteger)[coder decodeObjectForKey:@"_endDay"];
        _endYear = (NSInteger)[coder decodeObjectForKey:@"_endYear"];
        _eventDescription = [coder decodeObjectForKey:@"_eventDescription"];
        _location = [coder decodeObjectForKey:@"_location"];
        _category = [coder decodeObjectForKey:@"_category"];
        _summary = [coder decodeObjectForKey:@"_summary"];
    }
    return self;
}


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
    NSInteger event2Month = [otherEvent getStartMonth];
    NSInteger event2Day = [otherEvent getStartDay];
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
