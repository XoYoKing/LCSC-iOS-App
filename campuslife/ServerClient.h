//
//  ServerClient.h
//  LCSC
//
//  Created by x on 4/8/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerClient : NSObject <NSStreamDelegate> {
@public
    
    NSString *host;
    int port;
    
}



- (id) init;

- (void)testing;
- (void)setup;
- (void)open;
- (void)close;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)event;
- (void)readIn:(NSString *)s;
- (void)writeOut:(NSString *)s;

@end
