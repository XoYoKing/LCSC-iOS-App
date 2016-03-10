//
//  MenuViewController.m
//  LCSC
//
//  Created by Computer Science on 3/9/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "MenuViewController.h"
#import "SWRevealViewController.h"

@implementation MenuViewController
-(void)viewDidLoad
{
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
}
@end
