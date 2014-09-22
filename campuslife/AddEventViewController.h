//
//  AddEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This class is for the AddEvent page that is connected to the Calendar page!

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"
#import "AddEventParentViewController.h"

@interface AddEventViewController : AddEventParentViewController<GoogleOAuthDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UITextField *summary;
@property (strong, nonatomic) IBOutlet UITextField *where;
@property (strong, nonatomic) IBOutlet UITextView *description;

@property (strong, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (strong, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (strong, nonatomic) IBOutlet UIPickerView *categoryPicker;


@property (weak, nonatomic) IBOutlet UIButton *repFreqBtn;
@property (weak, nonatomic) IBOutlet UILabel *repUntilLabel;
@property (weak, nonatomic) IBOutlet UIButton *repUntilBtn;

-(void) refreshRecurrence;
-(IBAction) addEvent;
-(IBAction) allDayEventToggle:(id)sender;



@end