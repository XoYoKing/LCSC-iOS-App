//
//  MenuViewController.m
//  LCSC
//
//  Created by Computer Science on 3/9/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"
#import <TwitterKit/TwitterKit.h>

@implementation MenuViewController
-(void)viewDidLoad
{
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
//    [[Twitter sharedInstance] startWithConsumerKey:@"LCSC" consumerSecret: "@client"];
//    [Fabric with:@[[Twitter sharedInstance]]];
}
@end
