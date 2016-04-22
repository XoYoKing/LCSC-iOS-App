//
//  DataManager.m
//  LCSC
//
//  Created by x on 4/14/16.
//  Copyright © 2016 LCSC. All rights reserved.
//
#import <foundation/Foundation.h>
//#import "ServerClient.h"
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
const int CACHE_UPDATE_INTERVAL = 3600;
//ServerClient *serverClient;
time_t lastTime;
time_t currentTime;
time_t lastUpdate = 0;
pthread_t timeThreadStruct;
pthread_t saveCacheThreadStruct;
NSLock *timeLock;
NSLock *dataCacheLock;
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
        dataCacheLock = [[NSLock alloc] init];
        time(&lastTime);
        time(&lastUpdate);
        //serverClient = [[ServerClient alloc] init];
        //[self maintainCache];
        //[self getCache];
        elapsedTime = 1000;
        error = pthread_create(&timeThreadStruct, NULL, timeHeartBeat, NULL );
        if (error)
        {
            NSLog(@"DataManager: could not start time thread");
        }
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
        if (elapsedTime > CACHE_UPDATE_INTERVAL)
            [[DataManager singletonDataManager] maintainCache];
        [timeLock unlock];
        sleep(SLEEP_TIME);
    }
    return 0;
}
-(void) maintainCache
{
    [dataCacheLock lock];
    elapsedTime = 0;
    time(&currentTime);
    if (dataCache == nil)
    {
        [self rebuildCache];
        dataCache.lastUpdated = time(NULL);
        [self saveCache];
        [dataCacheLock unlock];
        return;
    }
    if (difftime(currentTime, dataCache.lastUpdated) > CACHE_UPDATE_INTERVAL)
    {
        [self rebuildCache];
        dataCache.lastUpdated = time(NULL);
        [self saveCache];
    }
    [dataCacheLock unlock];
}
-(void)saveCache
{
    error = pthread_create(&saveCacheThreadStruct, NULL, saveCacheThread, NULL );
}
void *saveCacheThread()
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
    return 0;
}
- (NSMutableDictionary*)rebuildCache
{
    dataCache = nil; //see getCache to understand this
    return [self getCache];
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
    if (data == nil)
        return [DataManager buildCache];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if (unarchiver == nil)
        return [DataManager buildCache];
    int version = [unarchiver decodeIntForKey:@"Version"];
    if (version == CACHE_VERSION)
    {
        dataCache = (DataCache*)[unarchiver decodeObjectForKey:@"MonthCache"];
        //check to see if cache is updated.
        return [dataCache monthCache];
    }
    return [DataManager buildCache];
}

+(NSMutableDictionary *) buildCache
{
    NSInteger startMonth = [CalendarInfo getCurrentMonth];
    NSInteger endMonth = startMonth;
    NSInteger startYear = [CalendarInfo getCurrentYear];
    NSInteger endYear = startYear;
    //NSInteger startDay, endDay = [CalendarInfo getCurrentDay];
    for (int i = 0; i < 6; i++) {
        [CalendarInfo incrementMonth:&endMonth :&endYear];
        //[CalendarInfo decrementMonth:&startMonth :&startYear];
    }
    dataCache = [[DataCache alloc] init];
    dataCache.monthCache = [DataManager buildCache:startMonth andYear:startYear
                                           toMonth:endMonth andYear:endYear];
    dataCache.lastUpdated = time(NULL);
    return [dataCache monthCache];
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
        int startYear = (int)event.startYear;
        int startMonth = (int)event.startMonth;
        int startDay = (int)event.startDay;
        currentKey = [DataManager getIndexStr:startMonth :startYear];
        currentMonth = [newMonthCache objectForKey:currentKey];
        NSLog(@"Building eventKey %@ monthDays %ld start day %ld", currentKey, (long)currentMonth.daysInMonth, (long)event.startDay);
        if (currentMonth == nil)
            currentMonth = [[MonthOfEvents alloc] initWithoutEvents:startMonth andYear:startYear];
        [newMonthCache setObject:currentMonth forKey:currentKey];
        [currentMonth addEvent:event toDay:startDay];
    }
    return newMonthCache;
}

//Not used for now
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
