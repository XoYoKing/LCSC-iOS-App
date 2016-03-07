//
//  ProfileViewController.m
//  LCSC
//
//  Created by Eric de Baere Grassl on 2/29/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "ProfileViewController.h"
#import "LCSC-Swift.h"


@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameDisplay;
@property (weak, nonatomic) IBOutlet UITextField *passwordDisplay;
@property (strong, nonatomic) Authentication *auth;
@end

@implementation ProfileViewController


- (void)changeDisplaytext:(NSString*)newLogin andPassword:(NSString*)newPassword{
    _usernameDisplay.text = newLogin;
    _passwordDisplay.text = newPassword;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _auth = [[Authentication alloc] init];
    NSString *username = [_auth getUsername];
    NSString *password = [_auth getPassword];
    [self changeDisplaytext:username andPassword:password];
}

- (IBAction)clearTapped:(id)sender {
    [_auth clearProfile];
    [self changeDisplaytext:@"" andPassword:@""];
}

- (IBAction)signinTapped:(id)sender {
    if (![_auth setProfile:_usernameDisplay.text newPassword:_passwordDisplay.text]){
        NSString *newLogin = [_auth getUsername];
        NSString *newPassword = [_auth getPassword];
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
