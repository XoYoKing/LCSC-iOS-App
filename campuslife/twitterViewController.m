//
//  twitterViewController.m
//  LCSC
//
//  Created by Computer Science on 3/10/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "twitterViewController.h"
#import <TwitterKit/TwitterKit.h>

@implementation twitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
    self.dataSource = [[TWTRUserTimelineDataSource alloc] initWithScreenName:@"LCSC" APIClient:client];
}



@end
