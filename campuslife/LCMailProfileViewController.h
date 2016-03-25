//
//  LCMailProfileViewController.h
//  LCSC
//
//  Created by Eric de Baere Grassl on 3/23/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSC-Swift.h"

@interface LCMailProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameDisplay;
@property (strong, nonatomic) Authentication *auth;
@property (strong, nonatomic) UIAlertView *alert;
@end
