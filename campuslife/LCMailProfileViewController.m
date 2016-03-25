//
//  LCMailProfileViewController.m
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/23/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "LCMailProfileViewController.h"

@implementation LCMailProfileViewController
- (void)changeDisplaytext:(NSString*)newLogin{
    _usernameDisplay.text = newLogin;
}

//clean the LCMail profile after tapping clear
- (IBAction)clearTapped:(id)sender {
    [_auth clearLCMailProfile];
    [self changeDisplaytext:@""];
}

//fill the text fiel with the user information after loading the view
- (void)viewDidLoad {
    [super viewDidLoad];
    _auth = [[Authentication alloc] init];
    // Do any additional setup after loading the view.
    NSString *username = [_auth getLCMailUsername];
    [self changeDisplaytext:username];
}

//Set the profile if it is valid
- (IBAction)signingTapped:(id)sender {
    if ([_auth setProfile:@"lcmail" newLogin:_usernameDisplay.text newPassword:@""]){
        NSString *newLogin = [_auth getLCMailUsername];
        [self changeDisplaytext:newLogin];
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Success!";
        _alert.message = @"Your LCMail username and password were saved.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Fail!";
        _alert.message = @"Your email has an invalid input. Don't forget to add the LCSC domain: @lcmail.lcsc.edu.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (![_auth setProfile:@"blackboard" newLogin:_usernameDisplay.text newPassword:@""]){
        NSString *newLogin = [_auth getLCMailUsername];
        [self changeDisplaytext:newLogin];
    }
}
@end
