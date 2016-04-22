//
//  ProfileViewController.m
//  LCSC
//
//  Created by Eric de Baere Grassl on 2/29/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "WarriorWebProfileViewController.h"
#import "LCSC-Swift.h"
//#import "SWRevealViewController.h"

@interface WarriorWebProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameDisplay;
@property (weak, nonatomic) IBOutlet UITextField *passwordDisplay;
@property (strong, nonatomic) Authentication *auth;
@property (strong, nonatomic) UIAlertView *alert;
@end

@implementation WarriorWebProfileViewController


- (void)changeDisplaytext:(NSString*)newLogin andPassword:(NSString*)newPassword{
    _usernameDisplay.text = newLogin;
    _passwordDisplay.text = newPassword;
}

//fill the text fiel with the user information after loading the view
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = [[UIImage alloc] init];
    img = [UIImage imageNamed:@"backgroundCollor"];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:img];
    
    _auth = [[Authentication alloc] init];
    
    _auth = [[Authentication alloc] init];
    NSString *username = [_auth getWarriorWebUsername];
    NSString *password = [_auth getWarriorWebPassword];
    [self changeDisplaytext:username andPassword:password];
}

//clean the WW profile after tapping clear
- (IBAction)clearTapped:(id)sender {
    [_auth clearWarriorWebProfile];
    [self changeDisplaytext:@"" andPassword:@""];
}


//Set the profile if it is valid
- (IBAction)signingTapped:(id)sender {
    if ([_auth setProfile:@"warriorweb" newLogin:_usernameDisplay.text newPassword:_passwordDisplay.text]){
        NSString *newLogin = [_auth getWarriorWebUsername];
        NSString *newPassword = [_auth getWarriorWebPassword];
        [self changeDisplaytext:newLogin andPassword:newPassword];
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Success!";
        _alert.message = @"Your WarriorWeb username and password were saved.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        _alert = [[UIAlertView alloc] init];
        _alert.title = @"Fail!";
        _alert.message = @"Your username or password have invalid input.";
        _alert.delegate = self;
        [_alert addButtonWithTitle:@"Ok"];
        [_alert show];
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if (![_auth setProfile:@"warriorweb" newLogin:_usernameDisplay.text newPassword:_passwordDisplay.text]){
        NSString *newLogin = [_auth getWarriorWebUsername];
        NSString *newPassword = [_auth getWarriorWebPassword];
        [self changeDisplaytext:newLogin andPassword:newPassword];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
