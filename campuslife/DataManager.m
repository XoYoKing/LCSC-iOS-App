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

@implementation DataManager
    ServerClient *serverClient;


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
        serverClient = [[ServerClient alloc] init];
        
        
        //NOTE for xero construct
    }
    
    
    return self;
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
