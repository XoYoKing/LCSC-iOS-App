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
#import "LCSC-Swift.h"

@implementation MenuViewController

-(void)viewDidLoad
{
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    Authentication* auth = [[Authentication alloc] init];
    if (![auth userHaveEverBeenAtResourcesPage]){
        [auth setUserHaveEverBeenAtResourcesPage:true];
        [self promptAlert:@"Your Profile is not set!" message:@"Some functionality may not work.\nDo you want to set your profile now?"];
    }
}

- (void)promptAlert:(NSString *)title message:(NSString *)message{
    UIAlertView* alert = [[UIAlertView alloc] init];
    alert.title = title;
    alert.message = message;
    alert.delegate = self;
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert show];
}

//choose the action based on which button the user presses in the alertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 1){
        [self performSegueWithIdentifier:@"Profile Alert" sender:self];
    }
}
@end
