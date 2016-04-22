//
//  LCSCEvent.h
//  LCSC
//
//  Created by Computer Science on 2/12/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LCSCEvent : NSObject<NSCoding>

// This constructor initializes the LCSCEvent object using the old NSDictionary structure
-(id)initWithNSDictionary:(NSDictionary *)dict;
-(NSComparisonResult)compare:(LCSCEvent *)otherEvent;


@property (readonly, getter=isAllDay) BOOL allDay;
@property (readonly, getter=getStartDay) NSInteger startDay;
@property (readonly, getter=getStartMonth) NSInteger startMonth;
@property (readonly, getter=getStartYear) NSInteger startYear;
@property (readonly, getter=getStartTimestamp) NSString *startTimestamp;

@property (readonly, getter=getEndDay) NSInteger endDay;
@property (readonly, getter=getEndMonth) NSInteger endMonth;
@property (readonly, getter=getEndYear) NSInteger endYear;
@property (readonly, getter=getEndTimestamp) NSString *endTimestamp;

@property (readonly, getter=getLocation) NSString *location;
@property (readonly, getter=getCategory) NSString *category;
@property (readonly, getter=getDescription) NSString *eventDescription;
@property (readonly, getter=getSummary) NSString *summary;

@end
