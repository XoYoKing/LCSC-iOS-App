//
//  BlackBoardProfileViewController.m
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/22/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "BlackBoardProfileViewController.h"
#import "LCSC-Swift.h"
//#import "SWRevealViewController.h"

@implementation BlackBoardProfileViewController

- (void)changeDisplaytext:(NSString*)newLogin andPassword:(NSString*)newPassword{
    _usernameDisplay.text = newLogin;
    _passwordDisplay.text = newPassword;
}

- (IBAction)clearTapped:(id)sender {
    [_auth clearBlackBoardProfile];
    [self changeDisplaytext:@"" andPassword:@""];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _auth = [[Authentication alloc] init];
    // Do any additional setup after loading the view.
//    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
//    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    NSString *username = [_auth getBlackBoardUsername];
    NSString *password = [_auth getBlackBoardPassword];
    [self changeDisplaytext:username andPassword:password];
}

- (IBAction)signingTapped:(id)sender {
    if ([_auth setProfile:@"blackboard" newLogin:_usernameDisplay.text newPassword:_passwordDisplay.text]){
        NSString *newLogin = [_auth getBlackBoardUsername];
        NSString *newPassword = [_auth getBlackBoardPassword];
        [self changeDisplaytext:newLogin andPassword:newPassword];
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Success!";
        _alert.message = @"Your BlackBoard username and password were saved.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Fail!";
        _alert.message = @"Your username or password have invalide input.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (![_auth setProfile:@"blackboard" newLogin:_usernameDisplay.text newPassword:_passwordDisplay.text]){
        NSString *newLogin = [_auth getBlackBoardUsername];
        NSString *newPassword = [_auth getBlackBoardPassword];
        [self changeDisplaytext:newLogin andPassword:newPassword];
    }
}


@end
