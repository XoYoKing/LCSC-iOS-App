//
//  ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

//This is for checking to see if an ipad is being used.
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#import "CalendarViewController.h"
#import "AllEventViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"
#import "AppDelegate.h"
#import "MonthFactory.h"
#import "MonthOfEvents.h"
#import "LCSCEvent.h"
#import "CalendarInfo.h"

@interface CalendarViewController ()


//This variable corresponds to the array id from MonthlyEvents.h/m
@property (nonatomic) int curArrayId;

@property (nonatomic) MonthlyEvents *events;

@property (nonatomic) NSDate *start;

@property (nonatomic) NSDate * firstDateOfMonth;

@property (nonatomic) NSDate * lastDateOfMonth;

@property (nonatomic) BOOL screenLocked;

//This is for delaying requests each time you switch between months.
@property (nonatomic) NSTimer *delayTimer;

@property (nonatomic) NSTimeInterval timeLastMonthSwitch;

@property (nonatomic) BOOL monthNeedsLoaded;

//These are for keeping track of the jsons that aren't being sent back to us.
@property (nonatomic) NSTimer *timer;

@property (nonatomic) NSTimeInterval timeLastReqSent;

@property (nonatomic) BOOL loadCompleted;

@property (nonatomic) BOOL allEventsDidLoad;

@property (nonatomic) int failedReqs;

@property (nonatomic) AppDelegate *appD;
@property (nonatomic) NSString *currentDateDay;
@property (nonatomic) NSString *currentDateMonth;
@property (nonatomic) NSString *currentDateYear;

@property (strong, nonatomic) NSCondition *condition;
@property (strong, nonatomic) NSThread *aThread;
@property (nonatomic) BOOL lock;

@property NSInteger currentMonth;
@property NSInteger currentYear;
@property MonthOfEvents *viewingMonth;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    _appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    _events = [MonthlyEvents getSharedInstance];
    
    Preferences *prefs = [Preferences getSharedInstance];
    
    //Here we load the actual state of the selected buttons.
    [_btnEntertainment setSelected:[prefs getPreference:@"Entertainment"]];
    [_btnAcademics setSelected:[prefs getPreference:@"Academics"]];
    [_btnStudentActivities setSelected:[prefs getPreference:@"Student Activities"]];
    [_btnResidenceLife setSelected:[prefs getPreference:@"Residence Life"]];
    [_btnWarriorAthletics setSelected:[prefs getPreference:@"Warrior Athletics"]];
    [_btnCampusRec setSelected:[prefs getPreference:@"Campus Rec"]];
    
    _leftArrow.enabled = NO;
    _rightArrow.enabled = NO;
    
    _failedReqs = 0;
    
    _curArrayId = 1;
    
    _shouldRefresh = NO;
    
    _loadCompleted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToCalendar)name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    
    _monthNeedsLoaded = NO;
    
    _timeLastMonthSwitch = 0;
    _timeLastReqSent = 0;
    
    
    _delayTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                   target: self
                                                 selector: @selector(onTickForDelay:)
                                                 userInfo: nil
                                                  repeats: YES];
    
    _leftArrow.enabled = YES;
    _rightArrow.enabled = YES;
    
    _swipeLeft.enabled = YES;
    _swipeRight.enabled = YES;
    _swipeUp.enabled = YES;
    _swipeDown.enabled = YES;
    
    
    _screenLocked = NO;
    
    _allEventsDidLoad = NO;
    
    _currentMonth = [CalendarInfo getCurrentMonth];
    _currentYear = [CalendarInfo getCurrentYear];
    
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];

    [_events setYear:(int)year];
    [_events setMonth:(int)month];
    
    [_events resetEvents];
    
    [_activityIndicator startAnimating];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    if ([_appD getHasService]){
        [self loadEvents];
        
        //[self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    }else{
  
        _shouldRefresh = YES;
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    _appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    if ([_appD getHasService]){
        if (_shouldRefresh) {
            [_activityIndicator startAnimating];
            
            [_events resetEvents];
            
            _curArrayId = 1;
            [self loadEvents];
            //[self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            
            _shouldRefresh = NO;
        }
        
        if(!_allEventsDidLoad) {
            self.lock = YES;
            
            // create the NSCondition instance
            self.condition = [[NSCondition alloc]init];
            
            self.aThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadLoop) object:nil];
            [self.aThread start];
            
            //[self rollbackEvents];
            _allEventsDidLoad = YES;
        }
    }else{
        [_activityIndicator stopAnimating];
        _shouldRefresh =YES;
    }
}


-(void) updateOutput{
    UINavigationController *navCont = [self.tabBarController.childViewControllers objectAtIndex:1];
    AllEventViewController *aevc = [navCont.childViewControllers objectAtIndex:0];
    [aevc loadAllData];
}

-(void)threadLoop
{
    while([[NSThread currentThread] isCancelled] == NO)
    {
        [self.condition lock];
        while(self.lock)
        {
            [self performSelector:@selector(updateOutput)
                         onThread:[NSThread mainThread]
                       withObject:nil
                    waitUntilDone:NO];
            [self.condition wait];
        }
        
        // lock the condition again
        self.lock = YES;
        [self.condition unlock];
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self rollbackEvents];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void)onTickForDelay:(NSTimer*)timer
{
    if (_monthNeedsLoaded
        && _timeLastMonthSwitch + 0.2 < [[NSDate date] timeIntervalSince1970])
    {
        
        [self loadEvents];
        _monthNeedsLoaded = NO;
        
        /*
         
         WTF is this code doing?
         
        _curArrayId = 1;
        if ([_events doesMonthNeedLoaded:_curArrayId])
        {
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
        else
        {
            [_collectionView reloadData];
            [_activityIndicator stopAnimating];

            
            _curArrayId = 2;
            if ([_events doesMonthNeedLoaded:_curArrayId])
            {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
            else
            {
                _curArrayId = 0;
                if ([_events doesMonthNeedLoaded:_curArrayId])
                {
                    [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                }
                else
                {
                    _loadCompleted = YES;

                    _screenLocked = NO;
                    [self.navigationItem setHidesBackButton:NO animated:YES];
                    _failedReqs = 0;
                }
            }
        }
         */
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)returnToCalendar
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)radioSelected:(UIButton *)sender
{
    Preferences *prefs = [Preferences getSharedInstance];
    
    NSString *categoryName = sender.titleLabel.text;
    
    if([categoryName  isEqual: @"Entertainment"])
    {
        [prefs negatePreference:categoryName]; //                              <-- Entertainment
        [_btnEntertainment setSelected:[prefs getPreference:categoryName]];
        [_btnEntertainment setHighlighted:NO];
    }
    else if([categoryName  isEqual: @"Academics"])
    {
        [prefs negatePreference:categoryName]; //                              <-- Academics
        [_btnAcademics setSelected:[prefs getPreference:categoryName]];
        [_btnAcademics setHighlighted:NO];
    }
    else if ([categoryName isEqual: @"Student Activities"])
    {
        [prefs negatePreference:categoryName]; //                              <-- Student Activities
        [_btnStudentActivities setSelected:[prefs getPreference:categoryName]];
        [_btnStudentActivities setHighlighted:NO];
    }
    else if ([categoryName  isEqual: @"Residence Life"])
    {
        [prefs negatePreference:categoryName]; //                              <-- Residence
        [_btnResidenceLife setSelected:[prefs getPreference:categoryName]];
        [_btnResidenceLife setHighlighted:NO];
    }
    else if ([categoryName isEqual: @"Warrior Athletics"])
    {
        [prefs negatePreference:categoryName]; //                              <-- Warrior Athletics
        [_btnWarriorAthletics setSelected:[prefs getPreference:categoryName]];
        [_btnWarriorAthletics setHighlighted:NO];
    }
    else
    {
        [prefs negatePreference:categoryName]; //                              <-- Campus Rec
        [_btnCampusRec setSelected:[prefs getPreference:categoryName]];
        [_btnCampusRec setHighlighted:NO];
    }
    
    [_collectionView reloadData];
}


// Runs when user clicks the back button on the calendar
// Set back the current month and year (if needed) and reload the events
- (IBAction)backMonthOffset:(id)sender {
    if (!_screenLocked)
    {

        [_activityIndicator startAnimating];
        [CalendarInfo decrementMonth:&_currentMonth :&_currentYear];
        //[_events offsetMonth:-1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [CalendarInfo getMonthBarDateOfMonth:_currentMonth], (long)_currentYear];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}

// Runs when user clicks the forward button on the calendar
// Set forward the current month and year (if needed), change the display thingy, and reload the events
- (IBAction)forwardMonthOffset:(id)sender {
    if (!_screenLocked)
    {

        [_activityIndicator startAnimating];
        [CalendarInfo incrementMonth:&_currentMonth :&_currentYear];
        
        
        //[_events offsetMonth:1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [CalendarInfo getMonthBarDateOfMonth:_currentMonth], (long)_currentYear];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    if ([_appD getHasService]){
    cells = 42;
    }else{
        cells = 0;
    }
    
    return cells;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    

    //Check to see if this cell is for a day of the previous month
    NSInteger firstWeekDay = [CalendarInfo getFirstWeekdayOfMonth:_currentMonth andYear:_currentYear];
    NSInteger daysOfMonth = [CalendarInfo getDaysOfMonth:(int)_currentMonth ofYear:(int)_currentYear];
    NSInteger daysOfPrevMonth = [CalendarInfo getDaysOfPreviousMonth:(int)_currentMonth ofYear:(int)_currentYear];
    
    if (indexPath.row+1 - firstWeekDay <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%ld", (int)indexPath.row+1 - firstWeekDay + daysOfPrevMonth];
    }
    
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - firstWeekDay > [CalendarInfo getDaysOfMonth:(int)_currentMonth ofYear:(int)_currentYear]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
       
        dayLbl.text = [NSString stringWithFormat:@"%ld", (int)indexPath.row+1 - firstWeekDay - daysOfMonth];
    }
    
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        /*
         if the table view cells border or shade on current day ever quits working look here.
         the if loop that controls the length of holdViewDay was written in december and I assumed
         that _currentDateMonth will be 01 - 09 for single digit months. if it turns out not to be
         come january then the check for length and appending a 0 to the string needs to be deleted
         
         all of the resets to cell layer and border were probably not needed, but I just wanted
         to be super through.
         */
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        dayLbl.text = [NSString stringWithFormat:@"%ld", (int)indexPath.row+1 - firstWeekDay];
        if ([dayLbl.text isEqualToString:_currentDateDay]){
            NSString *holdViewDay = [NSString stringWithFormat:@"%ld", (long)_currentMonth];
            if (holdViewDay.length != _currentDateMonth.length){
                holdViewDay = [NSString stringWithFormat:@"0%@",holdViewDay];
            }else{
                cell.layer.borderWidth=0.0f;
                cell.layer.borderColor=[UIColor clearColor].CGColor;
            }
            if ([holdViewDay isEqualToString: _currentDateMonth]){
                if ([[NSString stringWithFormat:@"%ld", (long)_currentYear] isEqualToString: _currentDateYear]){
                    ///edit the cell
                    cell.layer.borderWidth=0.5f;
                    cell.layer.borderColor=[UIColor blueColor].CGColor;
                    
                    //This is how you edit the color of the cell and not just the border.
                    //cell.backgroundColor = [UIColor colorWithRed:240.0/256.0 green:240.0/256.0 blue:240.0/256.0 alpha:1.0];
                }else{
       
                    cell.layer.borderWidth=0.0f;
                    cell.layer.borderColor=[UIColor clearColor].CGColor;
                }
            }else{
          
                cell.layer.borderWidth=0.0f;
                cell.layer.borderColor=[UIColor clearColor].CGColor;
            }
        }
        else{

            cell.layer.borderWidth=0.0f;
            cell.layer.borderColor=[UIColor clearColor].CGColor;
        }
        //Grab the squares for each category.
        UIView *entertainment = (UIView *)[cell viewWithTag:11];
        if (!entertainment.hidden) {
            entertainment.hidden = YES;
        }
        UIView *academics = (UIView *)[cell viewWithTag:12];
        if (!academics.hidden) {
            academics.hidden = YES;
        }
        UIView *studentActivities = (UIView *)[cell viewWithTag:13];
        if (!studentActivities.hidden) {
            studentActivities.hidden = YES;
        }
        UIView *residenceLife = (UIView *)[cell viewWithTag:14];
        if (!residenceLife.hidden) {
            residenceLife.hidden = YES;
        }
        UIView *warriorAthletics = (UIView *)[cell viewWithTag:15];
        if (!warriorAthletics.hidden) {
            warriorAthletics.hidden = YES;
        }
        UIView *campusRec = (UIView *)[cell viewWithTag:16];
        if (!campusRec.hidden) {
            campusRec.hidden = YES;
        }
        
        //This holds the preferences based on the legend at the top.
        Preferences *prefs = [Preferences getSharedInstance];
        
        //Showing relevant category by making the colorful squares not hidden anymore.
        //NSArray *dayEvents = [_events getEventsForDay:(int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        NSArray *dayEvents = [_viewingMonth getEventsForDay:(int)indexPath.row+1 - firstWeekDay];
        
        //Iterate through all events and determine categories that are present.
        for(LCSCEvent *event in dayEvents) {
            NSString *eventCategory = [event getCategory];
            
            if ([eventCategory isEqualToString:@"Entertainment"]) {
                if (entertainment.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        entertainment.hidden = NO;
                    }
                }
            }
            
            else if ([eventCategory isEqualToString:@"Academics"]) {
                if (academics.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        academics.hidden = NO;
                    }
                }
            }
            
            else if ([eventCategory isEqualToString:@"Student Activities"]) {
                if (studentActivities.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        studentActivities.hidden = NO;
                    }
                }
            }
            
            else if ([eventCategory isEqualToString:@"Resident Life"]) {
                if (residenceLife.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        residenceLife.hidden = NO;
                    }
                }
            }
            
            else if ([eventCategory isEqualToString:@"Warrior Athletics"]) {
                if (warriorAthletics.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        warriorAthletics.hidden = NO;
                    }
                }
            }
            
            else if ([eventCategory isEqualToString:@"Campus Rec"]) {
                if (campusRec.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:eventCategory]) {
                        campusRec.hidden = NO;
                    }
                }
            }
        }
    }
    
    return cell;
}

-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Day_Event_ViewController *destViewController = (Day_Event_ViewController *)[segue destinationViewController];
        
        //[destViewController setDay:indexPath.row+1 - [events getFirstWeekDay] ];
        
        [_events setSelectedDay:(int)indexPath.row+1 - [_events getFirstWeekDay:1]];

    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    
    if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - [_events getFirstWeekDay:1] <= 0) {
            if (!_screenLocked) {
                //Offset month if a previous month's cell is clicked
                [self backMonthOffset:nil];
            }

            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [_events getFirstWeekDay:1] > [_events getDaysOfMonth]) {
            
            if (!_screenLocked) {
                //Offset month if a future month's cell is clicked
                [self forwardMonthOffset:nil];
            }

            canSegue = NO;
        }
    }
    
    return canSegue;
}


- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day {
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian dateFromComponents:components];
}

- (NSString*)toStringFromDateTime:(NSDate*)dateTime {
    // Purpose: Return a string of the specified date-time in UTC (Zulu) time zone in ISO 8601 format.
    // Example: 2013-10-25T06:59:43.431Z
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
    NSString* sDateTime = [dateFormatter stringFromDate:dateTime];
    return sDateTime;
}

-(void) loadEvents
{
    _viewingMonth = [MonthFactory getMonthOfEventsFromMonth:_currentMonth andYear:_currentYear];
    [_collectionView reloadData];
    [_activityIndicator stopAnimating];
}

- (void) getEventsForMonth:(NSInteger) month :(NSInteger) year {

    NSDateFormatter *DateFormatter=[[NSDateFormatter alloc] init];
    [DateFormatter setDateFormat:@"dd"];
    _currentDateDay =[DateFormatter stringFromDate:[NSDate date]];
    [DateFormatter setDateFormat:@"MM"];
    _currentDateMonth =[DateFormatter stringFromDate:[NSDate date]];
    [DateFormatter setDateFormat:@"yyyy"];
    _currentDateYear =[DateFormatter stringFromDate:[NSDate date]];
    
    if (month+(_curArrayId-1) == 0)
    {
        _firstDateOfMonth = [self returnDateForMonth:12 year:year-1 day:1];
        _lastDateOfMonth = [self returnDateForMonth:13 year:year-1 day:0];
    }
    else if (month+(_curArrayId-1) == 13)
    {
        _firstDateOfMonth = [self returnDateForMonth:1 year:year+1 day:1];
        _lastDateOfMonth = [self returnDateForMonth:2 year:year+1 day:0];
    }
    else
    {
        _firstDateOfMonth = [self returnDateForMonth:month+(_curArrayId-1) year:year day:1];
        _lastDateOfMonth = [self returnDateForMonth:month+1+(_curArrayId-1) year:year day:0];
    }
    

    
    //_start = [NSDate date];
    
    if ([_events doesMonthNeedLoaded:_curArrayId])
    {
        if (_curArrayId == 1)
        {
            _screenLocked = NO;
        }
        

        
        // If user authorization is successful, then make an API call to get the event list for the current month.
        // For more infomation about this API call, visit:
        // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
        for (NSString *name in [_events getCategoryNames])
        {
            
            if (![_events getCalendarJsonReceivedForMonth:_curArrayId :name])
            {
                

                NSURL *url;
                NSString *calendarID = [[MonthlyEvents getSharedInstance] getCalIds][name];
                

                int urlMonth = [_events getSelectedMonth]+(_curArrayId-1);
                int urlYear = [_events getSelectedYear];
    
                if (urlMonth > 12){
                    urlMonth = 1;
                    urlYear++;
                }else if (urlMonth < 1){
                    urlMonth = 12;
                    urlYear--;
                }
       
                int urlendday = [_events getDaysOfMonth: urlMonth:[_events getSelectedYear]];

                
                if ([_events getSelectedMonth]+(_curArrayId-1) < 10 || [_events getSelectedMonth]+(_curArrayId-1) > 12){
                    
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-0%d-01T00:00:00-07:00&timeMax=%d-0%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,urlYear,urlMonth,urlYear,urlMonth,urlendday]];
                    
                }else{
                    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-%d-01T00:00:00-07:00&timeMax=%d-%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,urlYear,urlMonth,urlYear,urlMonth,urlendday]];
                }
                

                NSData *data = [NSData dataWithContentsOfURL:url];
                
                
                if (data != nil)
                {
                    [self parseJSON:data];
                }
                
                
                _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
                
                if (_loadCompleted)
                {
                    _loadCompleted = NO;
                    [self.navigationItem setHidesBackButton:YES animated:YES];
                }
            }

        }
        _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
    }
    else
    {
        if (_curArrayId == 1)
        {
            [_collectionView reloadData];
            [_activityIndicator stopAnimating];
            _screenLocked = NO;

            _loadCompleted = YES;
            
            _curArrayId = 2;
             if ([_events doesMonthNeedLoaded:_curArrayId])
             {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
             }
             else
             {
                 _curArrayId = 0;
                 if ([_events doesMonthNeedLoaded:_curArrayId])
                 {
                     [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                 }
             }
        }
        else if (_curArrayId == 2)
        {
            _curArrayId = 0;
            if ([_events doesMonthNeedLoaded:_curArrayId])
            {
                [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            }
        }
    }
}


#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
    
}



//-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData {
- (void) parseJSON:(NSData *)JSONAsData {
    NSError *error = nil;

    // Get the JSON data as a dictionary.

    NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:JSONAsData options:NSJSONReadingMutableContainers error:&error];

    



    
    if (error) {
        // This is the case that an error occured during converting JSON data to dictionary.
        // Simply log the error description.

    }
    else{
        //Get the events as an array

        NSMutableArray *oldEventsInfo = [eventsInfoDict valueForKey:@"items"];
        
        

        //////////////////////////////////////////
        NSArray *holdDict = [oldEventsInfo copy];
        for (int i=0; i<holdDict.count; i++){
            NSString *startTStuff = [[NSString alloc] init];
            NSString *endTStuff = [[NSString alloc] init];
            NSString *currentEndTime = [[holdDict[i] objectForKey:@"end"] objectForKey:@"dateTime"];
            NSString *currentStartTime = [[holdDict[i] objectForKey:@"start"] objectForKey:@"dateTime"];
            if (currentEndTime != nil) {
                startTStuff = [currentStartTime substringWithRange:NSMakeRange(10, [currentStartTime length]-10)];
                endTStuff = [currentEndTime substringWithRange:NSMakeRange(10, [currentStartTime length]-10)];
                int EnddayHold = [[currentEndTime substringWithRange:NSMakeRange(8, 2)] intValue];
                int StartdayHold = [[currentStartTime substringWithRange:NSMakeRange(8, 2)] intValue];
                if (abs(EnddayHold-StartdayHold)>1){
                    int yearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                    int monthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                    int daysInMonth = [_events getDaysOfMonth:monthHold :yearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){
                        int startyearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                        int startmonthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                        int amountOfStartDays = [_events getDaysOfMonth:startmonthHold :startyearHold];
                        amountOfDays = amountOfStartDays-StartdayHold+EnddayHold;
                    }
                    int counter = 0;
                    NSDictionary *holdRecurEvent = holdDict[i];
                    int newDay = StartdayHold;
                    for (int j = 0; j<amountOfDays ; j++,counter++,newDay++){
                        NSMutableDictionary *replacementEvent = [holdRecurEvent mutableCopy];
                        if (newDay > daysInMonth){
                            monthHold++;
                            if (monthHold >12){
                                monthHold = 1;
                                yearHold++;
                                j--;
                            }
                            newDay = 1;
                            daysInMonth = [_events getDaysOfMonth:monthHold :yearHold];
                            
                        }

                        NSString *SyearHold = [NSString stringWithFormat:@"%d",yearHold];
                        NSString *sMonthHold = [[NSString alloc] init ];
                        NSString *sDayHold = [[NSString alloc] init];
                        if (monthHold < 10){
                            sMonthHold = [NSString stringWithFormat:@"0%d",monthHold];
                        }else{
                            sMonthHold = [NSString stringWithFormat:@"%d",monthHold];
                        }
                        if (newDay < 10){
                            sDayHold = [NSString stringWithFormat:@"0%d",newDay];
                        }else{
                            sDayHold = [NSString stringWithFormat:@"%d",newDay];
                        }
                        NSString *newStartTime = [NSString stringWithFormat:@"%@-%@-%@%@",SyearHold,sMonthHold,sDayHold,startTStuff];
                        NSString *newEndDate = [NSString stringWithFormat:@"%@-%@-%@%@",SyearHold,sMonthHold,sDayHold,endTStuff];
                        NSMutableDictionary *holdDictStart = [[NSMutableDictionary alloc] init];
                        NSMutableDictionary *holdDictEnd = [[NSMutableDictionary alloc] init];
                        [holdDictStart setObject:newStartTime forKey:@"dateTime"];
                        [holdDictEnd setObject:newEndDate forKey:@"dateTime"];
                        [replacementEvent setObject:holdDictStart forKey:@"start"];
                        [replacementEvent setObject:holdDictEnd forKey:@"end"];

                        if (counter == 0){
                            oldEventsInfo[i] = replacementEvent;
                        }
                        else{
                            [oldEventsInfo addObject: replacementEvent];
                        }
                    }
                }
            }
            
            //fix for all day events
            currentStartTime = [[holdDict[i] objectForKey:@"start"] objectForKey:@"date"];
            currentEndTime = [[holdDict[i] objectForKey:@"end"] objectForKey:@"date"];
            if (currentEndTime != nil){
                int EnddayHold = [[currentEndTime substringWithRange:NSMakeRange(8, 2)] intValue];
                int StartdayHold = [[currentStartTime substringWithRange:NSMakeRange(8, 2)] intValue];

                if (abs(EnddayHold-StartdayHold)>1){

                    int startyearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                    int startmonthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];

                    int daysInMonth = [_events getDaysOfMonth:startmonthHold :startyearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){

                        int amountOfStartDays = [_events getDaysOfMonth:startmonthHold :startyearHold];
                        amountOfDays = amountOfStartDays-StartdayHold+EnddayHold;
                    }
                    if (amountOfDays >1) {
                        int counter = 0;
                        NSDictionary *holdRecurEvent = holdDict[i];
                        int newDay = StartdayHold;
                        int newEndDay = newDay + 1;
                        int endMonthHold = startmonthHold;
                        int endYearHold = startyearHold;
                        int daysInEndMonth = [_events getDaysOfMonth:endMonthHold :endYearHold];
                        for (int j = 0; j<amountOfDays-1 ; j++,counter++,newDay++,newEndDay++){
                            NSMutableDictionary *replacementEvent = [holdRecurEvent mutableCopy];
                            if (newDay > daysInMonth){
                                startmonthHold++;
                                if (startmonthHold >12){
                                    startmonthHold = 1;
                                    startyearHold++;
                                    j--;
                                }
                                newDay = 1;
                                daysInMonth = [_events getDaysOfMonth:startmonthHold :startyearHold];
                            }
                            if(newEndDay > daysInEndMonth){
                                endMonthHold++;
                                if (endMonthHold > 12){
                                    endMonthHold = 1;
                                    endYearHold++;
                                }
                                newEndDay = 1;
                                daysInEndMonth = [_events getDaysOfMonth:startmonthHold :startyearHold];
                                
                            }
                            NSString *SyearHold = [NSString stringWithFormat:@"%d",startyearHold];
                            NSString *sMonthHold = [[NSString alloc] init ];
                            NSString *sDayHold = [[NSString alloc] init];
                            NSString *EyearHold = [NSString stringWithFormat:@"%d",endYearHold];
                            NSString *eMonthHold = [[NSString alloc] init ];
                            NSString *eDayHold = [[NSString alloc] init];
                            if (startmonthHold < 10){
                                sMonthHold = [NSString stringWithFormat:@"0%d",startmonthHold];
                            }else{
                                sMonthHold = [NSString stringWithFormat:@"%d",startmonthHold];
                            }
                            if (newDay < 10){
                                sDayHold = [NSString stringWithFormat:@"0%d",newDay];
                            }else{
                                sDayHold = [NSString stringWithFormat:@"%d",newDay];
                            }
                            if (endMonthHold < 10){
                                eMonthHold = [NSString stringWithFormat:@"0%d",endMonthHold];
                            }else{
                                eMonthHold = [NSString stringWithFormat:@"%d",endMonthHold];
                            }
                            if (newEndDay < 10){
                                eDayHold = [NSString stringWithFormat:@"0%d",newEndDay];
                            }else{
                                eDayHold = [NSString stringWithFormat:@"%d",newEndDay];
                            }
                            NSString *newStartTime = [NSString stringWithFormat:@"%@-%@-%@",SyearHold,sMonthHold,sDayHold];
                            NSString *newEndDate = [NSString stringWithFormat:@"%@-%@-%@",EyearHold,eMonthHold,eDayHold];
                            NSMutableDictionary *holdDictStart = [[NSMutableDictionary alloc] init];
                            NSMutableDictionary *holdDictEnd = [[NSMutableDictionary alloc] init];
                            [holdDictStart setObject:newStartTime forKey:@"date"];
                            [holdDictEnd setObject:newEndDate forKey:@"date"];
                            [replacementEvent setObject:holdDictStart forKey:@"start"];
                            [replacementEvent setObject:holdDictEnd forKey:@"end"];
                            
                            if (counter == 0){
                                oldEventsInfo[i] = replacementEvent;
                            }
                            else{
                                [oldEventsInfo addObject: replacementEvent];
                            }
                        }
                    }
                }
            }
        }
        //////////////////////////////////////////
    
        if (oldEventsInfo == nil) {
            oldEventsInfo = [[NSMutableArray alloc] init];
        }
        
        NSString *category;

        for (NSString *name in [_events getCategoryNames])
        {
            //if ([self getIndexOfSubstringInString:name :[eventsInfoDict valueForKeyPath:@"summary"]] != -1) {
                category = name;
               
                
            //}
            //else{
            //}
        }
        //Convert the structure of the dictionaries in eventsInfo so that the dictionaries are compatible with the rest
        //of the app.

        NSMutableArray *eventsInfo = [[NSMutableArray alloc] init];
        for (int i=0; i<oldEventsInfo.count; i++)
        {
            //These will store the information that's needed for the event.
            NSString *startTime;
            NSString *endTime;
            //NSString *recur;
            NSArray *recurrence;
            NSString *location;
            NSString *summary;
            NSString *description;
   
            //This fix for days probably will cause a new years issue if the event goes till midnight on the first
            if ([oldEventsInfo[i] valueForKey:@"start"] != nil)
            {
                if ([oldEventsInfo[i] valueForKeyPath:@"start.dateTime"] != nil) {
                    if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSArray class]]) {
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"][0] valueForKey:@"dateTime"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"][0] valueForKey:@"dateTime"];
                    }
                    else if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSDictionary class]]){
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"] valueForKey:@"dateTime"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"] valueForKey:@"dateTime"];
                    }
                }else if ([oldEventsInfo[i] valueForKeyPath:@"start.date"] != nil){
                    if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSArray class]]) {
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"][0] valueForKey:@"date"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"][0] valueForKey:@"date"];
                    }
                    else if ([[oldEventsInfo[i] valueForKey:@"start"] isKindOfClass:[NSDictionary class]]){
                        startTime = [[oldEventsInfo[i] valueForKey:@"start"] valueForKey:@"date"];
                        endTime = [[oldEventsInfo[i] valueForKey:@"end"] valueForKey:@"date"];
                    }
                }
                

                if (endTime.length > 10){
                NSString *endMoment = [endTime substringWithRange:NSMakeRange(10, 9)];
                    if ([endMoment isEqual: @"T00:00:00"]){
                        NSString *endDayPart = [NSString stringWithFormat:@"%d",[[endTime substringWithRange:NSMakeRange(8, 2)] intValue]-1];
                        if ([endDayPart intValue] >0){
                        if (endDayPart.length < 2){
                            endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(9, 1) withString:endDayPart];
                        }else{
                            endTime = [endTime stringByReplacingCharactersInRange:NSMakeRange(8, 2) withString:endDayPart];
                        }
                        endTime = [endTime stringByReplacingOccurrencesOfString:@"T00:00:00" withString:@"T23:59:00"];

                        }
                    }
                }
            }

            if (([oldEventsInfo[i] valueForKey:@"location"] != nil))
            {
                location = [oldEventsInfo[i] valueForKey:@"location"];

            }else{
                location = @"No Location Provided";
            }
            
            if ([oldEventsInfo[i] valueForKey:@"description"] != nil)
            {
                description = [oldEventsInfo[i] valueForKey:@"description"];
                

            }
            else{
                description = @"No Description Provided";
            }
            
            if ([oldEventsInfo[i] valueForKey:@"summary"] != nil)
            {
                summary = [oldEventsInfo[i] valueForKey:@"summary"];
    
            }

            //This will be the new dictionary for the current event.
            NSDictionary *event;
            NSDictionary *start;
            NSDictionary *end;
            //Is the event an all day event?
            if ([startTime length] < 12)
            {
                start = [[NSDictionary alloc] initWithObjects:@[startTime] forKeys:@[@"date"]];
                end = [[NSDictionary alloc] initWithObjects:@[endTime] forKeys:@[@"date"]];
            }
            else
            {
                start = [[NSDictionary alloc] initWithObjects:@[startTime] forKeys:@[@"dateTime"]];
                end = [[NSDictionary alloc] initWithObjects:@[endTime] forKeys:@[@"dateTime"]];
            }

            if (recurrence == nil)
            {
                event = [[NSDictionary alloc] initWithObjects:@[category, location, summary, start, end, description] forKeys:@[@"category", @"location", @"summary", @"start", @"end", @"description"]];
               
            }
            else
            {
                event = [[NSDictionary alloc] initWithObjects:@[category, location, summary, start, end, description, recurrence] forKeys:@[@"category", @"location", @"summary", @"start", @"end", @"description", @"recurrence"]];
                
            }
            
            //Puts the new event into the new array of event dictionaries!
            [eventsInfo addObject:event];
        }
        

        
        if ([_events doesMonthNeedLoaded:_curArrayId])
        {
        
            [_events refreshArrayOfEvents:_curArrayId];
       

        }
        
        if (![_events getCalendarJsonReceivedForMonth:_curArrayId :category])
        {
            
            
            [_events setCalendarJsonReceivedForMonth:_curArrayId :category];
            if (_curArrayId == 1)
            {
                _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
                
            }

            int selectedMonth = [_events getSelectedMonth] + (_curArrayId-1);
            int selectedYear = [_events getSelectedYear];

            
            if (selectedMonth == 0)
            {
                selectedMonth = 12;
                selectedYear -= 1;
             
            }
            else if (selectedMonth == 13)
            {
                selectedMonth = 1;
                selectedYear += 1;

            }
            //Loop through the events
            for (int i=0; i<[eventsInfo count]; i++) {
                
                //Now we must parse the summary and alter the dictionary so that it can be
                //  used in the rest of the program easier. So we'll call parseSummaryForKey in this class
                //  to pull info out of the Summary field in the Dictionary and place
                //  it back into the dictionary mapped to a new key.

                NSMutableDictionary *currentEventInfo = [[NSMutableDictionary alloc] initWithDictionary:[eventsInfo objectAtIndex:i]];

                [currentEventInfo setObject:category forKey:@"category"];
                
 
                
                int startDay = 0;
                int startMonth = 0;
                int startYear = 0;
                
                int endDay = 0;
                
                
        
           
                //Determine if the event isn't an all day event type.
                if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"dateTime"] != nil) {
                    startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                  objectForKey:@"dateTime"]
                                 substringWithRange:NSMakeRange(8, 2)]
                                integerValue];
       
                    startMonth = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue];
                    
                    startYear = [[currentEventInfo[@"start"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue];
                    
                    //The endDay must not be the day of the month that it is on, but the number of days from the first day
                    //  of the startMonth.
                    if (startYear == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                        for (int month=startMonth; month<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                            endDay += [_events getDaysOfMonth:month :startYear];
                            
                        }
                        //Account for days in endMonth
                        endDay += [[[[currentEventInfo objectForKey:@"end"]
                                     objectForKey:@"dateTime"]
                                    substringWithRange:NSMakeRange(8, 2)]
                                   integerValue];
                    }
                    else {
                        //At the very beginning we'll be working with probably not a full year.
                        for (int month=startMonth; month<13; month++) {
                            endDay += [_events getDaysOfMonth:month :startYear];
                            
                        }
                        
                        //Start by accounting for year differences.
                        for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                            int endMonth = 12;
                            //This makes sure that we stop on the month prior to the selected month
                            //  and then add in the days for that month.
                            if (year == [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                endMonth = [[currentEventInfo[@"end"][@"dateTime"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                                //Account for days in endMonth
                                endDay += [[[[currentEventInfo objectForKey:@"end"]
                                             objectForKey:@"dateTime"]
                                            substringWithRange:NSMakeRange(8, 2)]
                                           integerValue];
                            }
                            
                            //This only takes into account full months strictly inbetween the start and end months.
                            for (int month=1; month<endMonth+1; month++) {
                                endDay += [_events getDaysOfMonth:month :year];
                                
                            }
                        }
                    }
                }
    
                else if ([[currentEventInfo objectForKey:@"start"] objectForKey:@"date"] != nil) {
                    startDay = (int)[[[[currentEventInfo objectForKey:@"start"]
                                  objectForKey:@"date"]
                                 substringWithRange:NSMakeRange(8, 2)]
                                integerValue];
                    
                    startMonth = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue];
                    
                    startYear = [[currentEventInfo[@"start"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue];
                    
                    //The endDay must not be the day of the month that it is on, but the number of days from the first day
                    //  of the startMonth.
                    if (startYear == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                        for (int month=startMonth; month<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]; month++) {
                            endDay += [_events getDaysOfMonth:month :startYear];
                            
                        }
                        //Account for days in endMonth
                        endDay += [[[[currentEventInfo objectForKey:@"end"]
                                     objectForKey:@"date"]
                                    substringWithRange:NSMakeRange(8, 2)]
                                   integerValue];
                    }
                    else {
                        //At the very beginning we'll be working with probably not a full year.
                        for (int month=startMonth; month<13; month++) {
                            endDay += [_events getDaysOfMonth:month :startYear];
                            
                        }
                        
                        //Start by accounting for year differences.
                        for (int year=startYear+1; year<[[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]+1; year++) {
                            int endMonth = 12;
                            //This makes sure that we stop on the month prior to the selected month
                            //  and then add in the days for that month.
                            if (year == [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(0, 4)] intValue]) {
                                endMonth = [[currentEventInfo[@"end"][@"date"] substringWithRange:NSMakeRange(5, 2)] intValue]-1;
                                //Account for days in endMonth

                                endDay += [[[[currentEventInfo objectForKey:@"end"]
                                             objectForKey:@"date"]
                                            substringWithRange:NSMakeRange(8, 2)]
                                           integerValue];
                            }
                            //This only takes into account full months strictly inbetween the start and end months.
                            for (int month=1; month<endMonth+1; month++) {
                                
                                endDay += [_events getDaysOfMonth:month :year];
                               
                                
                            }
                        }
                    }
                    //This makes the end day exclusive! As per the google calendar's standard.
                    endDay -= 1;
                }
                else if ([[currentEventInfo objectForKey:@"status"] isEqualToString:@"cancelled"])
                {
                    continue;
                }
                else
                {
                    continue;
                }
       
                float freq = 1.0;
                int repeat = 1;
                
                //If an event is reocurring, then we must account for that.
                
                
                //This will hold the number of days into the next month.
                int wrappedDays = endDay-[_events getDaysOfMonth:startMonth :startYear];
              

                //The e variable isn't being set properly. So fix it!
                
                int s = 0;
                int e = 0;
                
                //The outer loop loops through the reocurrences.
                for (int rep=0; rep<repeat; rep++) {
                    BOOL iterateOverDays = YES;
                    
                    //Are we dealing with a monthly repeat?
                    if (freq >= 28 && freq <= 31) {
                        freq = [_events getDaysOfMonth:startMonth :startYear];
                        
                    }
                    else if (freq >= 365 && freq <= 366) {
                        if (startYear % 4 == 0) {
                            freq = 366;
                        }
                        else {
                            freq = 365;
                        }
                    }

                    
                    //Here we setup the s and e variables for the for loop.
                    if (startYear == selectedYear) {
                        //The startMonth is with respect to the startDay. The endDay quite possible
                        //  can be going into the next month.
                        if (startMonth == selectedMonth) {
                            s = startDay;
                            
                            //Check if the endDay will be moving into the next month.
                            if (endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                                
                                e = [_events getDaysOfMonth:startMonth :startYear];
                                
                            }
                            else {
                                e = endDay;
                            }
                        }
                        //Check if the startMonth is the previous month and the endDay will roll over into the next month.
                        else if (startMonth + 1 == selectedMonth && endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                            
                            //We don't care about the days in the previous month, only that
                            //  the rolled over days are going to be in the selected month.
                            s = 1;
                            
                            //endDay is for sure going to be above the daysInMonth.
                            e = endDay%[_events getDaysOfMonth:startMonth :startYear];
                            
                        }
                        else {
                            //We'll skip this iterating, because we won't add anything.
                            iterateOverDays = NO;
                        }
                    }
                    else if (startYear == selectedYear-1
                             && startMonth == 12
                             && endDay > [_events getDaysOfMonth:startMonth :startYear]) {
                        
                        //We don't care about the days in the previous month, only that
                        //  the rolled over days are going to be in the selected month.
                        s = 1;
                        
                        //endDay is for sure going to be above the daysInMonth.
                        e = endDay%[_events getDaysOfMonth:startMonth :startYear];
                        
                    }
                    else {
                        //We'll skip this iterating, because we won't add anything.
                        iterateOverDays = NO;
                    }
                    if (iterateOverDays) {
                        //Add events for the startday all the way up to the end day.
                        for (int day=s; day<e+1; day++) {
                            if (day != 0) {
                                //This then uses that day as an index and inserts the currentEvent into that indice's array.
                                [_events AppendEvent:day :currentEventInfo :_curArrayId];
                            }
                        }
                    }
                    
                    //Setup the start and end vars for the next repeat.
                    startDay = startDay + freq;
                    
                    endDay = endDay + freq;
                    
                    BOOL nextDateUpdated = NO;
                    
                    while (!nextDateUpdated)
                    {
                        //Check if we're moving into a new month.
                        if (startDay%[_events getDaysOfMonth:startMonth :startYear] < startDay) {
                            
                            //Then we mod the startDay to get the day of the next month it will be on.
                            startDay = startDay-[_events getDaysOfMonth:startMonth :startYear];
                            
                            endDay = endDay-[_events getDaysOfMonth:startMonth :startYear];
                            
                            startMonth += 1;
                            
                            //Check to see if we transitioned to a new year.
                            if (startMonth > 12) {
                                startMonth = 1;
                                startYear += 1;
                            }
                            if (wrappedDays > 0) {
                                if (startMonth != 1) {
                                    endDay += [_events getDaysOfMonth:startMonth :startYear] - [_events getDaysOfMonth:startMonth-1 :startYear];
                                    
                                }
                                else {
                                    endDay += [_events getDaysOfMonth:startMonth :startYear] - [_events getDaysOfMonth:12 :startYear-1];
                                    
                                }
                            }
                        }
                        else
                        {
                            nextDateUpdated = YES;
                        }
                    }
                }
            

            }
            if ([_events isMonthDoneLoading:_curArrayId])
            {

                if (_curArrayId == 1)
                {
                    [_collectionView reloadData];
                    [_activityIndicator stopAnimating];

                    
                    _curArrayId = 2;
                    if ([_events doesMonthNeedLoaded:_curArrayId])
                    {
                        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                    }
                    else
                    {
                        _curArrayId = 0;
                        if ([_events doesMonthNeedLoaded:_curArrayId])
                        {
                            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                        }
                        else
                        {
                     
                           _screenLocked = NO;

                            _loadCompleted = YES;
                            [self.navigationItem setHidesBackButton:NO animated:YES];
                            _failedReqs = 0;
                        }
                    }
                }
                else if (_curArrayId == 2)
                {
                    _curArrayId = 0;
                    if ([_events doesMonthNeedLoaded:_curArrayId])
                    {
                        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
                    }
                    else
                    {
                        _screenLocked = NO;
                        _loadCompleted = YES;
                        [self.navigationItem setHidesBackButton:NO animated:YES];
                        _failedReqs = 0;
                    }
                }
                else
                {

                    _screenLocked = NO;
                    _loadCompleted = YES;
                    [self.navigationItem setHidesBackButton:NO animated:YES];
                    _failedReqs = 0;
                }
            }
        }
    }
}














@end