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

#import "XMLReader.h"
#import "CalendarViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"
#import "Authentication.h"
#import "AddEventParentViewController.h"

@interface CalendarViewController ()


//This variable correlates with the one from MonthlyEvents.h/m
@property (nonatomic) int curArrayId;

@property (nonatomic) MonthlyEvents *events;

@property (nonatomic) Authentication *auth;

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

@property (nonatomic) int authJsonReceived;

@property (nonatomic) int failedReqs;

@property (nonatomic) BOOL authenticating;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //NSLog(@"authorizing user");

    _auth = [Authentication getSharedInstance];
    
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
    
    _authJsonReceived = 0;
    
    _failedReqs = 0;

    _curArrayId = 1;
    
    _shouldRefresh = NO;
    
    _loadCompleted = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToCalendar)name:UIApplicationWillEnterForegroundNotification object:nil];
    

    _timer = [NSTimer scheduledTimerWithTimeInterval: 1
                                             target: self
                                           selector: @selector(onTick:)
                                           userInfo: nil
                                            repeats: YES];

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
    
    
    _screenLocked = YES;
    
    NSDate *date = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit | NSMonthCalendarUnit fromDate:date];
    NSInteger year = [dateComponents year];
    NSInteger month = [dateComponents month];
    
    [_events setYear:(int)year];
    [_events setMonth:(int)month];
    
    [_events resetEvents];
    
    [_auth resetPriviledges];
    
    [_activityIndicator startAnimating];
    
    _authenticating = YES;
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    [self authenticate];
    
    //NSLog(@"viewDidLoad was called");
}

- (void) viewDidAppear:(BOOL)animated {
    //NSLog(@"view appeared");
    
    [super viewDidAppear:YES];
    
    [_auth setDelegate:self];
    
    if (_shouldRefresh) {
        [_activityIndicator startAnimating];
        
        [_events resetEvents];
        
        _curArrayId = 1;
        
        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        
        _shouldRefresh = NO;
    }
    
    //NSLog(@"viewDidAppear was called");
}

- (void)onTick:(NSTimer*)timer
{
    if (_failedReqs == 3)
    {
        [_events resetEvents];
        _curArrayId = 1;
        
        _screenLocked = YES;
        
        [_collectionView reloadData];
        
        [_activityIndicator startAnimating];
        
        _failedReqs = 0;
        
        //Resend the requests that failed.
        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    }
    
    if (_authenticating)
    {
        //Have we received all of the authorization jsons after 3 seconds has passed?
        if (_authJsonReceived < [[_auth getCategoryNames] count]
            && _timeLastReqSent + (_failedReqs*2) + 3 < [[NSDate date] timeIntervalSince1970])
        {
            _failedReqs += 1;
            [self authenticate];
        }
    }
    else
    {
        //Check a bunch of conditions that altogether mean that the json that we're expecting
        //  hasn't been heard from for over 3 seconds. This hopefully means it won't be coming back.
        if (!_loadCompleted
            && _timeLastReqSent + (_failedReqs*2) + 3 < [[NSDate date] timeIntervalSince1970])
        {
            //[_events resetEvents];
            //_curArrayId = 1;
            
            _failedReqs += 1;
            
            //Resend the requests that failed.
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
    }
    
}

- (void)onTickForDelay:(NSTimer*)timer
{
    if (_monthNeedsLoaded
        && _timeLastMonthSwitch + 0.2 < [[NSDate date] timeIntervalSince1970])
    {
        _curArrayId = 1;
        if ([_events doesMonthNeedLoaded:_curArrayId])
        {
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
            _screenLocked = YES;
        }
        else
        {
            [_collectionView reloadData];
            [_activityIndicator stopAnimating];
            //NSLog(@"Collection view reloaded!");
            
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
                    //NSLog(@"Screen is no longer locked!");
                    _loadCompleted = YES;
                    _screenLocked = NO;
                    [self.navigationItem setHidesBackButton:NO animated:YES];
                    _failedReqs = 0;
                }
            }
        }
        
        _monthNeedsLoaded = NO;
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

- (IBAction)backMonthOffset:(id)sender {
    if (!_screenLocked)
    {
        //NSLog(@"went to previous month, jsons received: %d", _reqsSent);
        
        [_activityIndicator startAnimating];
        
        [_events offsetMonth:-1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}

- (IBAction)forwardMonthOffset:(id)sender {
    if (!_screenLocked)
    {
        //NSLog(@"went to next month, jsons received: %d", _reqsSent);

        [_activityIndicator startAnimating];
        
        [_events offsetMonth:1];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
        
        _timeLastMonthSwitch = [[NSDate date] timeIntervalSince1970];
        _monthNeedsLoaded = YES;
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    int cells;
    
    if (![_events doesMonthNeedLoaded:1]) {
        cells = 35;
        
        //NSLog(@"The number of cells required:%d", [events getFirstWeekDay] + [events getDaysOfMonth]-1);
        
        if ([_events getFirstWeekDay:1] + [_events getDaysOfMonth]-1 >= 35) {
            cells = 42;
        }
    }
    else {
        cells = 0;
    }
    
    return cells;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    
    //NSLog(@"The first weekday is:%d", [events getFirstWeekDay]);
    
    //NSLog(@"Check to see if cell is for next month:%d >= %d", indexPath.row+1 - [events getFirstWeekDay], [events getDaysOfMonth]);
    
    //Check to see if this cell is for a day of the previous month
    if (indexPath.row+1 - [_events getFirstWeekDay:1] <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1] + [_events getDaysOfPreviousMonth]];
    }
    //Check to see if this cell is for a day of the next month
    else if (indexPath.row+1 - [_events getFirstWeekDay:1] > [_events getDaysOfMonth]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1] - [_events getDaysOfMonth]];
    }
    else {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"CurrentDayCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        
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
        NSArray *dayEvents = [_events getEventsForDay:(int)indexPath.row+1 - [_events getFirstWeekDay:1]];
        
        //Iterate through all events and determine categories that are present.
        for (int i=0; i<[dayEvents count]; i++) {
            //NSString *category = [[dayEvents objectAtIndex:i] objectForKey:@"category"];
            
            //NSLog(@"The event's colorId is %d", [[[dayEvents objectAtIndex:i] objectForKey:@"colorId"] intValue]);
            
            if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Entertainment"]) {
                if (entertainment.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
                        entertainment.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Academics"]) {
                if (academics.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
                        academics.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Student Activities"]) {
                if (studentActivities.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
                        studentActivities.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Residence Life"]) {
                if (residenceLife.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
                        residenceLife.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Warrior Athletics"]) {
                if (warriorAthletics.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
                        warriorAthletics.hidden = NO;
                    }
                }
            }
            else if ([[[dayEvents objectAtIndex:i] objectForKey:@"category"] isEqualToString:@"Campus Rec"]) {
                if (campusRec.hidden) {
                    //Check to see if this category is selected.
                    if ([prefs getPreference:[[dayEvents objectAtIndex:i] objectForKey:@"category"]]) {
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
        
        //NSLog(@"The selected day is %d", (int)indexPath.row+1 - [_events getFirstWeekDay]);
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
            else
            {
                //NSLog(@"No segue for you!");
            }
            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - [_events getFirstWeekDay:1] > [_events getDaysOfMonth]) {
            if (!_screenLocked) {
                //Offset month if a future month's cell is clicked
                [self forwardMonthOffset:nil];
            }
            else
            {
                //NSLog(@"No segue for you!");
            }
            canSegue = NO;
        }
    }
    
    return canSegue;
}


//This is strictly for locating things like Category: and ShortDesc: within
//  the summary of the.
- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string {
    BOOL substringFound = NO;
    
    int substringStartIndex = -1;
    
    //Iterate through the string to find the first character in the substring.
    for (int i=0; i<[string length]; i++) {
        //Check to see if the substring character has been found.
        if ([string characterAtIndex:i] == [substring characterAtIndex:0]) {
            //If the substring length is greater than the remaining characters in the string,
            //  there is no possible way that the substring exists there (and an exception will be thrown.)
            //Only search for the substring if the remaining chars is >= to the substring length.
            if ([string length] - i >= [substring length]) {
                //Check to see if the following characters in the string are also in the substring.
                //  This can start at 1 because the 0th index of the substring has already been determined
                //  to be in the string.
                for (int j=1; j<[substring length]; j++) {
                    //Check if one the following characters in the substring aren't within the string.
                    if ([string characterAtIndex:i+j] != [substring characterAtIndex:j]) {
                        //If this is true, then i isn't the index of the first character in the substring
                        //  within the string.
                        break;
                    }
                    else {
                        //If this was the very last character in the substring and it's in the string, the
                        //  substring has been found. (The loop stops when it finds a char in the substring that's
                        //  not in the string.)
                        if (j == [substring length]-1) {
                            substringFound = YES;
                            substringStartIndex = i;
                        }
                    }
                }
            }
            //If we've found the substring, we can stop the loop.
            if (substringFound) {
                break;
            }
        }
    }
    
    return substringStartIndex;
}


//This is meant for parsing the summary, pulling out a chunk of information and putting it back
//  into the dictionary under a new key.
//@param eventDict This dictionary represents a single event that was received from Google Calendar's
//  json that will be given to us. The summary exists within this under the "summary" key.
//@param newKey This will be the key for the information that is pulled out of the summary and
//  placed back into the dictionary.
//@param possibleKeys Since human error is bound to happen, these are all the possible keys for
//  the single chunk of information that we're pulling out of the summary and placing back into
//  the dictionary under a new key.
//@return eventDict will be returned, but it will possibly have a new key (or an altered object
//  for a key if the user has permission to change events.)
-(NSDictionary *)parseSummaryForKey:(NSDictionary *)eventDict :(NSString *)newKey :(NSArray *)possibleKeys {
    NSMutableDictionary *dCurrentEvent = [[NSMutableDictionary alloc] initWithDictionary:eventDict];
    
    NSString *summary = [dCurrentEvent objectForKey:@"summary"];
    
    BOOL substringFound = NO;
    int substringStartIndex = 0;
    //This is the length of the key that was found to exist in the summary.
    int foundKeyLength = 0;
    
    //Loop through each possible key looking for the substring.
    //Then we'll break out of the look when it's found.
    for (int i=0; i<[possibleKeys count]; i++) {
        substringStartIndex = [self getIndexOfSubstringInString:[possibleKeys objectAtIndex:i] :summary];
        
        //-1 means a substring wasn't found.
        if (substringStartIndex != -1) {
            substringFound = YES;
            foundKeyLength = (int)[[possibleKeys objectAtIndex:i] length];
            break;
        }
    }
    
    if (substringFound) {
        //This block gets the first word after the "Category:", which is the category.
        NSString *infoWithExtraStuff = [summary substringWithRange:NSMakeRange(substringStartIndex+foundKeyLength,
                                                                               [summary length] - (substringStartIndex+foundKeyLength))];
        NSString *info = [[infoWithExtraStuff componentsSeparatedByString:@";"] objectAtIndex:0];
        
        int trailingSpaces = 0;
        
        //Determine number of trailing spaces, so we can not include them in the category.
        for (int j=(int)[info length]-1; j>=0; j--) {
            if ([info characterAtIndex:j] != ';') {
                break;
            }
            else {
                trailingSpaces += 1;
            }
        }
        
        //Add the category item to the dictionary.
        [dCurrentEvent setObject:[info substringWithRange:NSMakeRange(0, [info length] - trailingSpaces)]
                          forKey:newKey];
    }
    else {
        //If none of the possible keys were valid, then we can just assume say that there's
        //  no category and move on essentially.
        [dCurrentEvent setObject:@"N/A" forKey:newKey];
    }
    
    return (NSDictionary *)dCurrentEvent;
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

- (void) authenticate
{
    for (NSString *name in [_auth getCategoryNames])
    {
        if ([[_auth getAuthCals][name] isEqualToString:@"NO"])
        {
            //This is a dummy update that will be to see if the user is able to manage events.
            [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events/%@/move", [_auth getCalIds][name], [_auth getEventIds][name]]
                               withHttpMethod:httpMethod_POST
                           postParameterNames:[NSArray arrayWithObjects:@"destination", nil]
                          postParameterValues:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",[_auth getCalIds][name]], nil]
                                  requestBody:nil];
            _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
        }
    }
}

- (void) getEventsForMonth:(NSInteger) month :(NSInteger) year {
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
    
    //NSLog(@"Getting events for selected month, month:%@, year:%@", [self toStringFromDateTime:firstDateOfMonth], [self toStringFromDateTime:lastDateOfMonth]);
    
    //_start = [NSDate date];
    
    if ([_events doesMonthNeedLoaded:_curArrayId])
    {
        if (_curArrayId == 1)
        {
            _screenLocked = YES;
        }
        
        //NSLog(@"Sending requests");
        
        // If user authorization is successful, then make an API call to get the event list for the current month.
        // For more infomation about this API call, visit:
        // https://developers.google.com/google-apps/calendar/v3/reference/calendarList/list
        for (NSString *name in [_auth getCategoryNames])
        {
            if (![_events getCalendarJsonReceivedForMonth:_curArrayId :name])
            {
                [[_auth getAuthenticator] callAPI:[NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events", [_auth getCalIds][name]]
                                   withHttpMethod:httpMethod_GET
                               postParameterNames:[NSArray arrayWithObjects:@"timeMax", @"timeMin", nil]
                              postParameterValues:[NSArray arrayWithObjects:[self toStringFromDateTime:_lastDateOfMonth], [self toStringFromDateTime:_firstDateOfMonth], nil]
                                      requestBody:nil];
                
                _timeLastReqSent = [[NSDate date] timeIntervalSince1970];
                
                if (_loadCompleted)
                {
                    _loadCompleted = NO;
                    [self.navigationItem setHidesBackButton:YES animated:YES];
                }
            }
            else
            {
                //NSLog(@"%@ calendar has already been loaded for month %d", name, _curArrayId);
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

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData {
NSError *error = nil;
    //NSLog(@"json Incoming");
    
    if ([responseJSONAsString rangeOfString:@"calendar#events"].location != NSNotFound)
    {
        //NSLog(@"%@",responseJSONAsString);
        // Get the JSON data as a dictionary.

        NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
        //NSLog(@"Dictionary: %@", [eventsInfoDict descrip
        //NSLog(@"Dictionary: %@", [eventsInfoDict description]);
        
        
        if (error) {
            // This is the case that an error occured during converting JSON data to dictionary.
            // Simply log the error description.
            //NSLog(@"%@", [error localizedDescription]);
        }
        else{
            //Get the events as an array
            NSArray *eventsInfo = [eventsInfoDict objectForKey:@"items"];
            
            //NSLog(@"Putting the events into _calendarEvents.");
            
            NSString *category = @"";
            
            //NSLog(@"Jsons previously received: %d", _jsonsReceived);
            
            if ([_events doesMonthNeedLoaded:_curArrayId])
            {
                [_events refreshArrayOfEvents:_curArrayId];
                //NSLog(@"Refreshing current month");
            }
            
            category = eventsInfoDict[@"summary"];
            
            for (NSString *name in [_auth getCategoryNames])
            {
                if ([self getIndexOfSubstringInString:name :eventsInfoDict[@"summary"]] != -1) {
                    category = eventsInfoDict[@"summary"];
                }
            }
            
            if (![_events getCalendarJsonReceivedForMonth:_curArrayId :category])
            {
                //NSLog(@"Calendar received: %@", category);
                
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
                    
                    //NSLog(@"%@", currentEventInfo);
                    
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
                    if ([currentEventInfo objectForKey:@"recurrence"] != nil) {
                        //NSLog(@"recurrence: %@", currentEventInfo[@"recurrence"][0]);
                        
                        //The beginning of the substring that represents the freq of the recurrence.
                        int freqSubstringIndx = 11;
                        
                        //Thankfully there is only one semicolon in the string. So we use that to find the length of the frequency.
                        int freqLen = (int)[currentEventInfo[@"recurrence"][0] rangeOfString:@";"].location;
                        
                        freqLen -= freqSubstringIndx;
                        
                        //This will prevent any problems regarding the recurrence value.
                        //  Events that repeat forever will not be usable.
                        if (freqLen <= 250) {
                            NSString *frequency = [currentEventInfo[@"recurrence"][0] substringWithRange:NSMakeRange(freqSubstringIndx, freqLen)];
                            
                            //This 6 offsets the index so that it represents the beginning of the date we want.
                            int untilSubstringIndx = [self getIndexOfSubstringInString:@"UNTIL=":currentEventInfo[@"recurrence"][0]];
                            
                            if ([frequency isEqualToString:@"DAILY"]) {
                                freq = 1.0;
                            }
                            else if ([frequency isEqualToString:@"WEEKLY"]) {
                                freq = 7.0;
                            }
                            else if ([frequency isEqualToString:@"MONTHLY"]) {
                                freq = 31;
                            }
                            else if ([frequency isEqualToString:@"YEARLY"]) {
                                freq = 365;
                            }
                            
                            
                            
                            if (freq == 31) {
                                //Count the months between the start day and end day.
                                if (startYear == selectedYear) {
                                    for (int month=startMonth; month<selectedMonth; month++) {
                                        repeat += 1;
                                    }
                                }
                                else {
                                    //At the very beginning we'll be working with probably not a full year.
                                    for (int month=startMonth; month<13; month++) {
                                        repeat += 1;
                                    }
                                    
                                    //Start by accounting for year differences.
                                    for (int year=startYear+1; year<[_events getSelectedYear]+1; year++) {
                                        int endMonth = 12;
                                        //This makes sure that we stop on the month prior to the selected month
                                        //  and then add in the days for that month.
                                        if (year == selectedYear) {
                                            endMonth = selectedMonth-1;
                                        }
                                        //This only takes into account full months strictly inbetween the start and end months.
                                        for (int month=1; month<endMonth+1; month++) {
                                            repeat += 1;
                                        }
                                    }
                                }
                            }
                            else if (freq == 365) {
                                if (startYear != selectedYear){
                                    for (int year=startYear; year<selectedYear; year++) {
                                        repeat += 1;
                                    }
                                }
                            }
                            else if (untilSubstringIndx != -1) {
                                //In here we'll determine the number of ocurrences.
                                
                                untilSubstringIndx += 6;
                                //Get the until substring
                                NSString *untilString = [currentEventInfo[@"recurrence"][0] substringFromIndex:untilSubstringIndx];
                                
                                //Determine if the start and end are within the selected month.
                                if (startYear == [[untilString substringWithRange:NSMakeRange(0,4)] intValue]
                                    && startMonth == [[untilString substringWithRange:NSMakeRange(4,2)] intValue]
                                    && startYear == selectedYear
                                    && startMonth == selectedMonth) {
                                    repeat = (([[untilString substringWithRange:NSMakeRange(6,2)] intValue] - startDay)/freq) + 1;
                                }
                                //If they aren't then we need to determine the amount of days between the start and end.
                                else {
                                    //Add up all of the days for the months inbetween the start and end. Then do the same formula to calculate the repeat.
                                    
                                    //We know that at least the startMonth is not within the selected month.
                                    
                                    //These days is just the length from start to finish no matter if there are some holes in the middle.
                                    float daysInEventDuration = 0.0;
                                    
                                    if (startYear == selectedYear) {
                                        //Account for days in startMonth
                                        daysInEventDuration += [_events getDaysOfMonth:startMonth :startYear]-startDay+1;
                                        
                                        if (selectedMonth < [[untilString substringWithRange:NSMakeRange(4,2)] intValue]) {
                                            for (int month=startMonth+1; month<[_events getSelectedMonth]+1; month++) {
                                                daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                            }
                                        }
                                        else {
                                            for (int month=startMonth+1; month<[_events getSelectedMonth]; month++) {
                                                daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                            }
                                            //Account for days in endMonth
                                            daysInEventDuration += [[untilString substringWithRange:NSMakeRange(6,2)] intValue];
                                        }
                                    }
                                    else {
                                        //Account for days in startMonth
                                        daysInEventDuration += [_events getDaysOfMonth:startMonth :startYear]-startDay+1;
                                        
                                        //At the very beginning we'll be working with probably not a full year.
                                        for (int month=startMonth+1; month<13; month++) {
                                            daysInEventDuration += [_events getDaysOfMonth:month :startYear];
                                        }
                                        
                                        //Start by accounting for year differences.
                                        for (int year=startYear+1; year<[_events getSelectedYear]+1; year++) {
                                            int endMonth = 12;
                                            //This makes sure that we stop on the month prior to the selected month
                                            //  and then add in the days for that month.
                                            if (year == selectedYear) {
                                                endMonth = selectedMonth-1;
                                                //Account for days in endMonth
                                                daysInEventDuration += [[untilString substringWithRange:NSMakeRange(6,2)] intValue];
                                            }
                                            
                                            //This only takes into account full months strictly inbetween the start and end months.
                                            for (int month=1; month<endMonth+1; month++) {
                                                daysInEventDuration += [_events getDaysOfMonth:month :year];
                                            }
                                        }
                                    }
                                    
                                    repeat = (daysInEventDuration / freq) + 1;
                                    
                                    //NSLog(@"The repeat number is %d", repeat);
                                }
                            }
                            NSUInteger substringIndx = [self getIndexOfSubstringInString:@"INTERVAL=":currentEventInfo[@"recurrence"][0]];
                            if (substringIndx != -1)
                            {
                                NSString *substring = [currentEventInfo[@"recurrence"][0] substringFromIndex:substringIndx+9];
                                substringIndx = [self getIndexOfSubstringInString:@";":currentEventInfo[@"recurrence"][0]];
                                if (substringIndx == -1)
                                {
                                    substringIndx = [substring length];
                                }
                                freq *= [[substring substringWithRange:NSMakeRange(0,substringIndx)] intValue];
                            }
                        }
                    }
                    
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
                            else if (startMonth + 1 == selectedMonth
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
                    //NSLog(@"Monthid=%d is done loading.", _curArrayId);
                    if (_curArrayId == 1)
                    {
                        [_collectionView reloadData];
                        [_activityIndicator stopAnimating];
                        //NSLog(@"Collection view reloaded!");
                        
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
                                //NSLog(@"Screen is no longer locked!");
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
                            //NSLog(@"Screen is no longer locked!");
                            _screenLocked = NO;
                            _loadCompleted = YES;
                            [self.navigationItem setHidesBackButton:NO animated:YES];
                            _failedReqs = 0;
                        }
                    }
                    else
                    {
                        //NSLog(@"Screen is no longer locked!");
                        _screenLocked = NO;
                        _loadCompleted = YES;
                        [self.navigationItem setHidesBackButton:NO animated:YES];
                        _failedReqs = 0;
                    }
                }
            }
        }
    }
    //This type of json is retrieved if an update was made to an event (currently only for authenticating.)
    else if ([responseJSONAsString rangeOfString:@"calendar#event"].location != NSNotFound) {
        [_auth setUserCanManageEvents:YES];

        _addEventButton.title = @"Add Event";
        _addEventButton.enabled = YES;
        
        NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:responseJSONAsData options:NSJSONReadingMutableContainers error:&error];
        
        //BOOL foundCal = NO;
        
        for (NSString *name in [_auth getCategoryNames])
        {
            if ([self getIndexOfSubstringInString:name :eventsInfoDict[@"organizer"][@"displayName"]] != -1) {
                [[_auth getAuthCals] setObject:@"YES" forKey:name];
                //foundCal = YES;
            }
        }
        
        /*
        //This is for checking to see if there was a authorized category that doesn't have a calendar name associated with it.
        if (!foundCal)
        {
            NSLog(@"auth problems");
        }*/
        
        _authJsonReceived += 1;
        
        if (_authJsonReceived == 6)
        {
            _authenticating = NO;
            _failedReqs = 0;
            _curArrayId = 1;
            [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
        }
        
        //NSLog(@"Authenticated Calendar: %@", category);
    }
}

-(void)accessTokenWasRevoked{
    [_events resetEvents];
    _loadCompleted = YES;
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    //NSLog(@"Error:%@", errorShortDescription);
    //NSLog(@"Details:%@", errorDetails);
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: errorShortDescription
                                                    message: errorDetails
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
     */
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    //NSLog(@"Error:%@", errorMessage);
    
    if ([self getIndexOfSubstringInString:@"403" :errorMessage] != -1
       && [self getIndexOfSubstringInString:@"Forbidden" :errorMessage] != -1)
    {
        _authJsonReceived += 1;
    }
    
    if (_authJsonReceived == 6)
    {
        _authenticating = NO;
        _failedReqs = 0;
        _curArrayId = 1;
        [self getEventsForMonth:[_events getSelectedMonth] :[_events getSelectedYear]];
    }
}

@end