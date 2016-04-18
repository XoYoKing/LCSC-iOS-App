//
//  DataCache.m
//  LCSC
//
//  Created by x on 4/17/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_monthCache forKey:@"_monthCache"];
    [encoder encodeObject:_monthCacheRevision forKey:@"_monthCacheRevision"];
    [encoder encodeObject:[NSDate dateWithTimeIntervalSince1970:_lastUpdated] forKey:@"_lastUpdated"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        _monthCache = [coder decodeObjectForKey:@"_monthCache"];
        _monthCacheRevision =[coder decodeObjectForKey:@"_monthCacheRevision"];
        _lastUpdated = (time_t)[coder decodeObjectForKey:@"_lastUpdated"];
    }
    return self;
}

@end
