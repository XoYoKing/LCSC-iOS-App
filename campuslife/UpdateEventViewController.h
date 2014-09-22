//
//  UpdateEventViewController.h
//  campuslife
//
//  Created by Super Student on 12/8/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"
#import "AddEventParentViewController.h"

@interface UpdateEventViewController : AddEventParentViewController<GoogleOAuthDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

//This will be given to us from the previous class (EventDetailViewController)
@property (nonatomic, strong, setter=setEventInfo:) NSDictionary *eventInfo;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UITextField *summary;
@property (weak, nonatomic) IBOutlet UITextField *where;
@property (weak, nonatomic) IBOutlet UITextView *description;

@property (weak, nonatomic) IBOutlet UISwitch *allDayEventSwitch;

@property (weak, nonatomic) IBOutlet UIDatePicker *startTimePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endTimePicker;

@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;

@property (weak, nonatomic) IBOutlet UIButton *repFreqBtn;
@property (weak, nonatomic) IBOutlet UILabel *repUntilLabel;
@property (weak, nonatomic) IBOutlet UIButton *repUntilBtn;

-(void) refreshRecurrence;
-(IBAction) addEvent;
-(IBAction) allDayEventToggle:(id)sender;


@end
