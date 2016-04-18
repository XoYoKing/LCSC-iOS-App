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
#include <pthread.h>
#include <time.h>

@implementation DataManager

const int CACHE_VERSION = 1;
const int SLEEP_TIME = 10; //time in seconds
ServerClient *serverClient;
time_t lastTime;
time_t currentTime;
pthread_t timeThreadStruct;
NSLock *timeLock;
bool timeKeeperActive = true;
bool error = false;
double elapsedTime = 0.0;



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
        serverClient = [[ServerClient alloc] init];
        error = pthread_create(&timeThreadStruct, NULL, timeHeartBeat, NULL );
        if (error)
        {
            NSLog(@"DataManager: could not start time thread");
        }
        //NOTE for xero construct
    }
    
    
    return self;
}


double probeTime()
{
    //[timeLock lock];
    double getTime = elapsedTime;
    //[timeLock unlock];
    return getTime;
}
void resetTime()
{
    [timeLock lock];
    elapsedTime = 0.0;
    [timeLock unlock];
}
void *timeHeartBeat()
{
    while(timeKeeperActive)
    {
        time(&currentTime);
        [timeLock lock];
        elapsedTime += difftime(currentTime, lastTime);
        lastTime = currentTime;
        [timeLock unlock];
        sleep(SLEEP_TIME);
    }
    return 0;
}

- (void)saveCache:(NSMutableDictionary*)cache
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
            [archiver encodeObject:cache forKey:@"MonthCache"];
            [archiver finishEncoding];
            fileSaved = [data writeToFile:dataPath atomically:YES];
        }
    }
}
- (NSMutableDictionary*)getCache
{
    //NSURL *documentDirectoryURL = [[[NSFileManager defaultManager]
    //                                URLsForDirectory:NSCachesDirectory
    //                                inDomains:NSUserDomainMask]
    //                               lastObject];
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* dataPath = [documentsDirectory stringByAppendingString:@"\/CalendarCache"];
    return [self getCache:dataPath];
}
- (NSMutableDictionary*)getCache:(NSString*)path
{
    NSData* data = [NSData dataWithContentsOfFile:path];
    //NSMutableDictionary* monthCache;
    //if([[NSFileManager defaultManager] fileExistsAtPath:path])
    if (data)
    {
        NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        if (unarchiver)
        {
            int version = [unarchiver decodeIntForKey:@"Version"];
            if (version == CACHE_VERSION)
            {
                return (NSMutableDictionary*)[unarchiver decodeObjectForKey:@"MonthCache"];
                
            }
        }
    }
    return nil;
}
- (bool)doesCacheExist
{
    
    return false;
}


- (bool)isCacheUpdated
{
    //NOTE for xero construct
    return false;
}


@end
