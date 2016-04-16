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
        //NOTE for xero construct
    }
    
    
    return self;
}


double probeTime()
{
    [timeLock lock];
    double getTime = elapsedTime;
    [timeLock unlock];
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
        [timeLock unlock];
        lastTime = currentTime;
        sleep(SLEEP_TIME);
    }
    return 0;
}



- (NSMutableDictionary*)getCache
{
    //x: check the file structure for the serialized month cache structure.
    
    return nil;
}

- (bool)doesCacheExist
{
    //NOTE for xero constrcut
    return false;
}


- (bool)isCacheUpdated
{
    //NOTE for xero construct
    return false;
}


@end
