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
@end
