//
//  AddEventViewController.m
//  campuslife
//
//  Created by Super Student on 12/2/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This is for checking to see if an ipad is being used.
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


#import "AddEventViewController.h"
#import "Authentication.h"
#import "MonthlyEvents.h"
#import "CalendarViewController.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

@interface AddEventViewController () {
    CGFloat animatedDistance;
}

@property (nonatomic) Authentication *auth;

//The stepper button will cycle through the possible categories.
@property (nonatomic, strong) NSArray *categories;

@end

@implementation AddEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(tap:)];
    [self.view addGestureRecognizer: tapRec];
    
    _auth = [Authentication getSharedInstance];
    
    [_auth setDelegate:self];
    
    NSMutableArray *cats = [[NSMutableArray alloc] init];
    
    for (NSString* categoryName in [_auth getAuthCals]) {
        if ([[[_auth getAuthCals] objectForKey:categoryName] isEqualToString:@"YES"]) {
            [cats addObject:categoryName];
        }
    }
    
    _categories = [[NSArray alloc] initWithArray:[cats sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
    
    [_categoryPicker reloadAllComponents];
    [_categoryPicker selectRow:(int)floor(_categories.count/2.) inComponent:0 animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refreshRecurrence];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (IDIOM != IPAD) {
        [_scrollView layoutIfNeeded];
        _scrollView.contentSize = CGSizeMake(320, 1200);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) refreshRecurrence
{
    //NSLog(@"RepFreq: %@", super.repeatFreq);
    //NSLog(@"RepUntil: %@", super.repeatUntil);
    
    if ([super.repeatFreq isEqualToString:@"Never"])
    {
        _repFreqBtn.titleLabel.text = @"Never";
        
        _repUntilBtn.enabled = NO;
        _repUntilBtn.titleLabel.text = @"mm/dd/yyyy";
        _repUntilBtn.titleLabel.textColor = [UIColor grayColor];
        [_repUntilBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        
        super.repeatUntil = NULL;
    }
    else
    {
        _repFreqBtn.titleLabel.text = super.repeatFreq;
        _repUntilBtn.enabled = YES;
        _repUntilBtn.titleLabel.textColor = [UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM/dd/yyyy"];
        
        if (super.repeatUntil != NULL) {
            _repUntilBtn.titleLabel.text = [dateFormatter stringFromDate:super.repeatUntil];
        }
        else {
            super.repeatUntil = _startTimePicker.date;
            
            _repUntilBtn.titleLabel.text = [dateFormatter stringFromDate:super.repeatUntil];
        }
    }
}
-(IBAction) addEvent {
    BOOL readyToAddEvent = YES;
    
    //Check if fields are left blank. Notice the description and where fields aren't required.
    if ([_summary.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Blank Field"
                                                        message: @"The Summary field is empty, please fill it in and try again."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self refreshRecurrence];
        
        readyToAddEvent = NO;
    }
    //We will do some other checking on the start and end times to see if they are valid.
    
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"MM"];
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"dd"];

    //See if comparing the dates is needed.
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"yyyy"];
    
    //Check if the end year is less than the start year
    if ([[yearFormatter stringFromDate:_endTimePicker.date] intValue]
        < [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                        message: @"The end year is less than the start year."
                                                       delegate: nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        [self refreshRecurrence];
        
        readyToAddEvent = NO;
    }
    else if ([[yearFormatter stringFromDate:_endTimePicker.date] intValue]
             == [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
    {
        //Now we check the months.
        if ([[monthFormatter stringFromDate:_endTimePicker.date] intValue]
            < [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                            message: @"The end month is less than the start month."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self refreshRecurrence];
        }
        else if ([[monthFormatter stringFromDate:_endTimePicker.date] intValue]
                 == [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
        {
            //Now we check the days.
            if ([[dayFormatter stringFromDate:_endTimePicker.date] intValue]
                < [[dayFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Date"
                                                                message: @"The end day is less than the start day."
                                                               delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                [self refreshRecurrence];
                
                readyToAddEvent = NO;
            }
            else if ([[dayFormatter stringFromDate:_startTimePicker.date] intValue]
                     == [[dayFormatter stringFromDate:_endTimePicker.date] intValue])
            {
                //We compare the times regardless of the type of event (all-day, non all-day.)
                NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
                [timeFormatter setDateFormat:@"HHmm"];
                
                //check those times.
                if ([[timeFormatter stringFromDate:_endTimePicker.date] intValue]
                    < [[timeFormatter stringFromDate:_startTimePicker.date] intValue])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Time"
                                                                    message: @"The end time is less than the start time."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    [self refreshRecurrence];
                    
                    readyToAddEvent = NO;
                }
            }
        }
    }

    if (super.repeatUntil != NULL)
    {
        //We must see if the recurrence will be before or on the start of the event.
        if ([[yearFormatter stringFromDate:super.repeatUntil] intValue]
            < [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Repeat Until"
                                                            message: @"The year is less than the start year."
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self refreshRecurrence];
            
            readyToAddEvent = NO;
        }
        else if ([[yearFormatter stringFromDate:super.repeatUntil] intValue]
                 == [[yearFormatter stringFromDate:_startTimePicker.date] intValue])
        {
            if ([[monthFormatter stringFromDate:super.repeatUntil] intValue]
                < [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Repeat Until"
                                                                message: @"The month is less than the start month."
                                                               delegate: nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                [self refreshRecurrence];
                
                readyToAddEvent = NO;
            }
            else if ([[monthFormatter stringFromDate:super.repeatUntil] intValue]
                     == [[monthFormatter stringFromDate:_startTimePicker.date] intValue])
            {
                if([[dayFormatter stringFromDate:super.repeatUntil] intValue]
                   <= [[dayFormatter stringFromDate:_startTimePicker.date] intValue])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Invalid Repeat Until"
                                                                    message: @"The day is less than or equal to the start day."
                                                                   delegate: nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                    [self refreshRecurrence];
                    
                    readyToAddEvent = NO;
                }
            }
        }
    }

    NSString *calId = [_auth getCalIds][_categories[[_categoryPicker selectedRowInComponent:0]]];

    if (readyToAddEvent) {
         NSMutableDictionary *json = [[NSMutableDictionary alloc] init];
        
        //Events have specified time constraints unless they are all day events.
        if (!_allDayEventSwitch.on) {
            [json setObject:_summary.text forKey:@"summary"];
            //[json setObject:_description.text forKey:@"description"];
            [json setObject:_where.text forKey:@"location"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
            

            [json setObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:_startTimePicker.date], @"dateTime",
                             [[NSTimeZone localTimeZone] name], @"timeZone",nil] forKey:@"start"];
            [json setObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:_endTimePicker.date], @"dateTime",
                             [[NSTimeZone localTimeZone] name], @"timeZone", nil] forKey:@"end"];
            
            
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            
            //Weekly Repeat
            if ([super.repeatFreq isEqualToString:@"Weekly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=WEEKLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Bi-Weekly Repeat
            else if ([super.repeatFreq isEqualToString:@"Bi-Weekly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Monthly Repeat
            else if ([super.repeatFreq isEqualToString:@"Monthly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=MONTHLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Yearly Repeat
            else if ([super.repeatFreq isEqualToString:@"Yearly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=YEARLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Event"
                                                            message: @"Your event has been sent to the Google Calendar!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self refreshRecurrence];
            
        }
        else {
            [json setObject:_summary.text forKey:@"summary"];
            //[json setObject:_description.text forKey:@"description"];
            [json setObject:_where.text forKey:@"where"];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *endDate = _endTimePicker.date;
            endDate = [endDate dateByAddingTimeInterval:86400];

            [json setObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:_startTimePicker.date], @"date",
                             [[NSTimeZone localTimeZone] name], @"timeZone",nil] forKey:@"start"];
            [json setObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:endDate], @"date",
                             [[NSTimeZone localTimeZone] name], @"timeZone", nil] forKey:@"end"];
            
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            
            //Weekly Repeat
            if ([super.repeatFreq isEqualToString:@"Weekly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=WEEKLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Bi-Weekly Repeat
            else if ([super.repeatFreq isEqualToString:@"Bi-Weekly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=WEEKLY;INTERVAL=2;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Monthly Repeat
            else if ([super.repeatFreq isEqualToString:@"Monthly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=MONTHLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            //Yearly Repeat
            else if ([super.repeatFreq isEqualToString:@"Yearly"]) {
                [json setObject:@[[NSString stringWithFormat:@"RRULE:FREQ=YEARLY;UNTIL=%@T120000Z", [dateFormatter stringFromDate:super.repeatUntil]]] forKey:@"recurrence"];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"New Event"
                                                            message: @"Your all day event has been sent to the Google Calendar!"
                                                           delegate: nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
            [self refreshRecurrence];
        }
        
        [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/", calId]
                           withHttpMethod:httpMethod_POST
                       postParameterNames:@[]
                      postParameterValues:@[]
                              requestBody:json];
        
        CalendarViewController *controller = (CalendarViewController *) self.navigationController.viewControllers[1];
        [controller setShouldRefresh:YES];
        
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}

- (IBAction)allDayEventToggle:(id)sender {
    if (_allDayEventSwitch.on) {
        _startTimePicker.datePickerMode = UIDatePickerModeDate;
        _endTimePicker.datePickerMode = UIDatePickerModeDate;
    }
    else {
        _startTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
        _endTimePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    //NSLog(@"allDaySwitch is on: %d %d", _allDayEventSwitch.on, _endTimePicker.hidden);
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //One column
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //set number of rows
    return _categories.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //set item per row
    return [_categories objectAtIndex:row];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


- (void)textViewDidBeginEditing:(UITextField *)textField {
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    
    CGFloat numerator = midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =[[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

//This limits the characters within the date and time text fields to two characters and will display an alert if an invalid number is entered.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    BOOL charShouldChange = YES;
    
    //This accounts for the year field (because it allows 4 characters.)
    if (textField.tag == 30) {
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 4) ? NO : YES;
    }
    else if (textField.tag == 1){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 54) ? NO : YES;
    }
    else if (textField.tag == 2){
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        charShouldChange = (newLength > 28) ? NO : YES;
    }
    return charShouldChange;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return textView.text.length + (text.length - range.length) <= 200;
}

- (void)textViewDidEndEditing:(UITextField *)textField {
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}


-(void)tap:(UITapGestureRecognizer *)tapRec{
    [[self view] endEditing: YES];
}



#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
    //NSLog(@"%@", responseJSONAsString);
}

-(void)accessTokenWasRevoked{
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    //NSLog(@"%@", errorShortDescription);
    //NSLog(@"%@", errorDetails);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: errorShortDescription
                                                    message: errorDetails
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self refreshRecurrence];
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    //NSLog(@"%@", errorMessage);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"There was an error in adding the event!"
                                                    message: errorMessage
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
    [self refreshRecurrence];
}

@end