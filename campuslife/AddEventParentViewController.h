//
//  AddEventParentViewController.h
//  campuslife
//
//  Created by Super Student on 2/18/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddEventParentViewController : UIViewController

@property(strong, nonatomic, setter=setRepFreq:) NSString *repeatFreq;
@property(strong, nonatomic, setter=setRepUntil:, getter=getRepUntil) NSDate *repeatUntil;

@property (weak, nonatomic) IBOutlet UITextView *descriptionView;

@end
