//
//  ServerClient.m
//  LCSC
//
//  Created by x on 4/8/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "ServerClient.h"
#include <netinet/in.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <pthread.h>
#include <resolv.h>
#include <netdb.h>


const int RequestCode = 066;
const int PortNumber = 5666;
CFReadStreamRef readStream;
CFWriteStreamRef writeStream;

NSInputStream *inputStream;
NSOutputStream *outputStream;

pthread_t workThread;
bool error; //set if there was an error
static ServerClient* sc = nil;

@implementation ServerClient


- (id) init
{
    self = [super init];
    if(self)
    {
        sc = self;
        error = pthread_create(&workThread, NULL, requestData, NULL );
        if(error)
        {
            NSLog(@"ServerClient: error creating work thread ");
        }
        
    }
    return self;
}

void *requestData()
{
    //len = res_query(host, C_IN, T_MX, &answer, sizeof(answer));
    char hostname[] = "isoptera.lcsc.edu";
    struct hostent *he;
    struct in_addr **addr_list;
    if ((he=gethostbyname(hostname)) == NULL)
    {
        NSLog(@"ServerClient: Error resolving host isoptera.lcsc.edu");
        error = true;
        return NULL;
    }
    addr_list = (struct in_addr **) he->h_addr_list;
    if (addr_list[0] == NULL)
    {
        error = true;
        return NULL;
    }
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_port = htons(PortNumber);
    server_addr.sin_addr.s_addr = inet_addr(inet_ntoa(*addr_list[0]));  //NOTE to xero verify this works
    server_addr.sin_addr.s_addr = inet_addr("192.168.94.1"); //test address
    server_addr.sin_family = AF_INET;
    int i = connect(clientSocket, (const struct sockaddr *)&server_addr, sizeof(server_addr));
    if (i >= 0)
    {
        NSLog(@"Connected to Server");
    }
    
    //Code conversation with server
    
    close(clientSocket);
    
    return NULL;
}


- (void)testing
{
    //len = res_query(host, C_IN, T_MX, &answer, sizeof(answer));
    char hostname[] = "isoptera.lcsc.edu";
    struct hostent *he;
    struct in_addr **addr_list;
    int j;
    if ((he=gethostbyname(hostname)) == NULL)
    {
        NSLog(@"ServerClient: Error resolving host isoptera.lcsc.edu");
        error = true;
        return;
    }
    addr_list = (struct in_addr **) he->h_addr_list;
    if (addr_list[0] == NULL)
    {
        error = true;
        return;
    }
    int clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    struct sockaddr_in server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_port = htons(PortNumber);
    server_addr.sin_addr.s_addr = inet_addr(inet_ntoa(*addr_list[0]));  //NOTE to xero verify this works
    server_addr.sin_addr.s_addr = inet_addr("192.168.94.1"); //test address
    server_addr.sin_family = AF_INET;
    int i = connect(clientSocket, (const struct sockaddr *)&server_addr, sizeof(server_addr));
    if (i >= 0)
    {
        NSLog(@"Connected to Server");
    }
    
    
    close(clientSocket);
    
}


- (void)setup {
    NSURL *url = [NSURL URLWithString:host];
    
    NSLog(@"Setting up connection to %@ : %i", [url absoluteString], port);
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)[url host], port, &readStream, &writeStream);
    
    if(!CFWriteStreamOpen(writeStream)) {
        NSLog(@"Error, writeStream not open");
        
        return;
    }
    [self open];
    
    NSLog(@"Status of outputStream: %lu", (unsigned long)[outputStream streamStatus]);
    
    return;
}

- (void)open {
    NSLog(@"Opening streams.");
    
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    //[inputStream retain];
    //[outputStream retain];
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream open];
    [outputStream open];
}

- (void)close {
    NSLog(@"Closing streams.");
    
    [inputStream close];
    [outputStream close];
    
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    
    //[inputStream release];
    //[outputStream release];
    
    inputStream = nil;
    outputStream = nil;
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)event {
    NSLog(@"Stream triggered.");
    
    switch(event) {
        case NSStreamEventHasSpaceAvailable: {
            if(stream == outputStream) {
                NSLog(@"outputStream is ready.");
                [self writeOut:@"test999"];
            }
            break;
        }
        case NSStreamEventHasBytesAvailable: {
            if(stream == inputStream) {
                NSLog(@"inputStream is ready.");
                
                uint8_t buf[1024];
                unsigned int len = 0;
                
                len = [inputStream read:buf maxLength:1024];
                
                if(len > 0) {
                    NSMutableData* data=[[NSMutableData alloc] initWithLength:0];
                    
                    [data appendBytes: (const void *)buf length:len];
                    
                    NSString *s = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                    
                    
                    
                    [self readIn:s];
                    NSLog(@"%@", s );                    //[data release];
                }
                else{
                    NSError *error = [inputStream streamError];
                    NSLog(@"%@", [error description]);
                }
            }
            break;
        }
        default: {
            NSLog(@"Stream is sending an Event: %lu", (unsigned long)event);
            
            break;
        }
    }
}

- (void)readIn:(NSString *)s
{
    NSLog(@"Reading in the following:");
    NSLog(@"%@", s);
}

- (void)writeOut:(NSString *)s {
    uint8_t *buf = (uint8_t *)[s UTF8String];
    NSError *error = [inputStream streamError];
    NSLog(@"%@", [error description]);
    
    [outputStream write:buf maxLength:strlen((char *)buf)];
    
    NSLog(@"Writing out the following:");
    NSLog(@"%@", s);
    //NSError *error = [inputStream streamError];
    NSLog(@"%@", [error description]);
}

@end
