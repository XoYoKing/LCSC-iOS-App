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

//clean the BB profile after tapping clear
- (IBAction)clearTapped:(id)sender {
    [_auth clearBlackBoardProfile];
    [self changeDisplaytext:@"" andPassword:@""];
}

//fill the text fiel with the user information after loading the view
- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundCollor")!)
    UIImage *img = [[UIImage alloc] init];
    img = [UIImage imageNamed:@"backgroundCollor"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:img];
    _auth = [[Authentication alloc] init];

    NSString *username = [_auth getBlackBoardUsername];
    NSString *password = [_auth getBlackBoardPassword];
    [self changeDisplaytext:username andPassword:password];
}

//Set the profile if it is valid
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
        _alert.message = @"Your username or password is invalid.";
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
