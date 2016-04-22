//
//  DataCache.h
//  LCSC
//
//  Created by x on 4/17/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject<NSCoding>

@property (nonatomic, strong) NSMutableDictionary *monthCache;
@property (nonatomic, strong) NSMutableDictionary *monthCacheRevision;
@property (nonatomic) time_t lastUpdated;
@end
