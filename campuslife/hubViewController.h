//
//  hubViewController.h
//  campuslife
//
//  Created by Super Student on 5/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface hubViewController : UIViewController <GoogleOAuthDelegate>

-(IBAction)signInToGoogleCalendar:(id)sender;

@end
