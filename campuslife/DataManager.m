//
//  DataManager.m
//  LCSC
//
//  Created by x on 4/14/16.
//  Copyright © 2016 LCSC. All rights reserved.
//
#import <foundation/Foundation.h>
#import "ServerClient.h"
#import "DataManager.h"
#import "CalendarInfo.h"
#import "JsonParser.h"
#import "DataCache.h"
#import <pthread.h>
#import <time.h>
#import "MonthOfEvents.h"
#import "MonthFactory.h"

@implementation DataManager
const int CACHE_VERSION = 1;
const int SLEEP_TIME = 10; //time in seconds
//ServerClient *serverClient;
time_t lastTime;
time_t currentTime;
time_t lastUpdate = 0;
pthread_t timeThreadStruct;
NSLock *timeLock;
bool timeKeeperActive = true;
bool error = false;
double elapsedTime = 0.0;
DataCache *dataCache = nil;

+ (id)singletonDataManager{
    static DataManager *singletonDataManager = nil;
    @synchronized(self) {
        if(singletonDataManager == nil)
            singletonDataManager = [[self alloc] init];
    }
    return singletonDataManager;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        timeLock = [[NSLock alloc] init];
        time(&lastTime);
        //serverClient = [[ServerClient alloc] init];
        error = pthread_create(&timeThreadStruct, NULL, timeHeartBeat, NULL );
        if (error)
        {
            NSLog(@"DataManager: could not start time thread");
        }
        //NOTE for xero construct
    }
    
    
    return self;
}

void *timeHeartBeat()
{
    while(timeKeeperActive)
    {
        time(&currentTime);
        [timeLock lock];
        elapsedTime += difftime(currentTime, lastTime); //elapsedTime in seconds
        lastTime = currentTime;
        [timeLock unlock];
        sleep(SLEEP_TIME);
    }
    return 0;
}

- (void)saveCache
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dataPath = [documentsDirectory stringByAppendingString:@"\/CalendarCache"];
    NSMutableData* data = [[NSMutableData alloc] init];
    bool fileSaved = false;
    if (data)
    {
        NSKeyedArchiver* archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        if (archiver)
        {
            [archiver encodeInt:1 forKey:@"Version"];
            [archiver encodeObject:dataCache forKey:@"MonthCache"];
            [archiver finishEncoding];
            fileSaved = [data writeToFile:dataPath atomically:YES];
        }
    }
}
- (NSMutableDictionary*)getCache
{
    if (dataCache != nil)
        return [dataCache monthCache];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dataPath = [documentsDirectory stringByAppendingString:@"\/CalendarCache"];
    return [self getCache:dataPath];
}
- (NSMutableDictionary*)getCache:(NSString*)path
{
    NSData* data = [NSData dataWithContentsOfFile:path];
    if (data)
        return nil;
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if (unarchiver)
        return nil;
    int version = [unarchiver decodeIntForKey:@"Version"];
    if (version == CACHE_VERSION)
    {
        dataCache = (DataCache*)[unarchiver decodeObjectForKey:@"MonthCache"];
        return [dataCache monthCache];
    }
    return nil;
}
+(NSMutableDictionary *) buildCache:(NSInteger)startMonth andYear:(NSInteger) startYear
                            toMonth:(NSInteger) endMonth andYear:(NSInteger)endYear
{
    NSMutableDictionary *newMonthCache = [[NSMutableDictionary alloc] init];
    NSMutableArray *events = (NSMutableArray *)[JsonParser loadEventsFromMonth:startMonth andYear:startYear
                                                                         toMonth:endMonth andYear:endYear];
    MonthOfEvents *currentMonth;
    NSString *currentKey;
    for(LCSCEvent *event in events)
    {
        for(int i = (int)event.startYear; i <= event.endYear; i++)
        {
            for (int j = (int)event.startMonth; j<=((i ==event.endYear) ? event.endMonth : 12); j++)
            {
                currentKey = [DataManager getIndexStr:j :i];
                currentMonth = [newMonthCache objectForKey:currentKey];
                if (currentMonth == nil)
                    currentMonth = [[MonthOfEvents alloc] initWithoutEvents:j andYear:i];
                [newMonthCache setObject:currentMonth forKey:currentKey];
                [currentMonth addEvent:event toDay:event.startDay];
            }
        }
    }
    return newMonthCache;
}
+(NSMutableArray*)getMonthKeys:(LCSCEvent*)event  :(void (^)(int days))processDays
{
    NSMutableArray *keyList = [[NSMutableArray alloc] init];
    //int daysInMonth;
    for(int i = (int)event.startYear; i <= event.endYear; i++)
    {
        for (int j = (int)event.startMonth; j<=((i ==event.endYear) ? event.endMonth : 12); j++)
        {
            [keyList addObject:[DataManager getIndexStr:j :i]];
            //[keyList addObject:[CalendarInfo getDaysOfMonth:j ofYear:i]];
            //[daysList addObject:<#(nonnull id)#>]
            
            processDays([CalendarInfo getDaysOfMonth:j ofYear:i]);
        }
    }
    return keyList;
}
+(NSString *)getIndexStr:(NSInteger)month :(NSInteger)year
{
    return [NSString stringWithFormat:@"%ld-%ld", (long)year, (long)month];
}@end
