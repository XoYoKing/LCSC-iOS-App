//
//  BlackBoardProfileViewController.h
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/22/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSC-Swift.h"


@interface BlackBoardProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameDisplay;
@property (weak, nonatomic) IBOutlet UITextField *passwordDisplay;
@property (strong, nonatomic) Authentication *auth;
@property (strong, nonatomic) UIAlertView *alert;
@end
