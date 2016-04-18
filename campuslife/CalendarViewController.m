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
#import "Preferences.h"
#import "AppDelegate.h"
#import "MonthFactory.h"
#import "LCSCEvent.h"
#import "CalendarInfo.h"
#import "Day_Event_ViewController.h"
#import "SWRevealViewController.h"

@interface CalendarViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (nonatomic) BOOL screenLocked;

//This is for delaying requests each time you switch between months.
@property (nonatomic) NSTimer *delayTimer;

@property (nonatomic) NSTimeInterval timeLastMonthSwitch;

@property (nonatomic) BOOL monthNeedsLoaded;

//These are for keeping track of the jsons that aren't being sent back to us.

@property (nonatomic) BOOL loadCompleted;

@property (nonatomic) AppDelegate *appD;
@property (nonatomic) NSString *currentDateDay;
@property (nonatomic) NSString *currentDateMonth;
@property (nonatomic) NSString *currentDateYear;

@property NSInteger selectedMonth;
@property NSInteger selectedYear;
@property MonthOfEvents *viewingMonth;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    _appD = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [super viewDidLoad];
    
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    
    // Do any additional setup after loading the view, typically from a nib.
    Preferences *prefs = [Preferences getSharedInstance];
    
    //Here we load the actual state of the selected buttons.
    
    _leftArrow.enabled = NO;
    _rightArrow.enabled = NO;
    
    _shouldRefresh = NO;
    
    _loadCompleted = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToCalendar)name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    
    _monthNeedsLoaded = NO;
    
    _timeLastMonthSwitch = 0;
    
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
    
    _selectedMonth = [CalendarInfo getCurrentMonth];
    _selectedYear = [CalendarInfo getCurrentYear];
    
    [_activityIndicator startAnimating];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    if ([_appD getHasService]){
        [self loadEvents];
        
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
            
            [self loadEvents];
            
            _shouldRefresh = NO;
        }

    }else{
        [_activityIndicator stopAnimating];
        _shouldRefresh =YES;
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
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


// Runs when user clicks the back button on the calendar
// Set back the current month and year (if needed) and reload the events
- (IBAction)backMonthOffset:(id)sender {
    if (!_screenLocked)
    {
        [_activityIndicator startAnimating];
        [CalendarInfo decrementMonth:&_selectedMonth :&_selectedYear];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [CalendarInfo getMonthBarDateOfMonth:_selectedMonth], (long)_selectedYear];
        
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
        [CalendarInfo incrementMonth:&_selectedMonth :&_selectedYear];
        
        _monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [CalendarInfo getMonthBarDateOfMonth:_selectedMonth], (long)_selectedYear];
        
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
    NSInteger firstWeekDay = [CalendarInfo getFirstWeekdayOfMonth:_selectedMonth andYear:_selectedYear];
    NSInteger daysOfMonth = [CalendarInfo getDaysOfMonth:(int)_selectedMonth ofYear:(int)_selectedYear];
    NSInteger daysOfPrevMonth = [CalendarInfo getDaysOfPreviousMonth:(int)_selectedMonth ofYear:(int)_selectedYear];
    
    // The cell is for a day of the previous month
    if (indexPath.row+1 - firstWeekDay <= 0) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
        
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - firstWeekDay + daysOfPrevMonth];
    }
    
    // The cell represents a day in the next month
    else if (indexPath.row+1 - firstWeekDay > [CalendarInfo getDaysOfMonth:(int)_selectedMonth ofYear:(int)_selectedYear]) {
        cell = (UICollectionViewCell *)[_collectionView dequeueReusableCellWithReuseIdentifier:@"OtherMonthCell" forIndexPath:indexPath];
        
        UILabel *dayLbl = (UILabel *)[cell viewWithTag:100];
       
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - firstWeekDay - daysOfMonth];
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
        dayLbl.text = [NSString stringWithFormat:@"%d", (int)indexPath.row+1 - firstWeekDay];
        if ([dayLbl.text isEqualToString:_currentDateDay]){
            NSString *holdViewDay = [NSString stringWithFormat:@"%ld", (long)_selectedMonth];
            if (holdViewDay.length != _currentDateMonth.length){
                holdViewDay = [NSString stringWithFormat:@"0%@",holdViewDay];
            }else{
                cell.layer.borderWidth=0.0f;
                cell.layer.borderColor=[UIColor clearColor].CGColor;
            }
            if ([holdViewDay isEqualToString: _currentDateMonth]){
                if ([[NSString stringWithFormat:@"%ld", (long)_selectedYear] isEqualToString: _currentDateYear]){
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
        
        Day_Event_ViewController *destViewController = (Day_Event_ViewController *)[segue destinationViewController];
        
        NSInteger selectedDay = indexPath.row+1 - [CalendarInfo getFirstWeekdayOfMonth:_selectedMonth
                                                                               andYear:_selectedYear];
        NSMutableArray *eventsToShow = [[NSMutableArray alloc] init];
        Preferences *prefs = [Preferences getSharedInstance];
        for(LCSCEvent *event in [_viewingMonth getEventsForDay:selectedDay]) {
            if([prefs getPreference:[event getCategory]]) {
                [eventsToShow addObject:event];
            }
        }
        [destViewController setDay:selectedDay];
        [destViewController setEvents:eventsToShow];
    }
}


- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    BOOL canSegue = YES;
    NSInteger firstWeekDay = [CalendarInfo getFirstWeekdayOfMonth:_selectedMonth
                                                          andYear:_selectedYear];
    
    if ([identifier isEqualToString:@"CalendarToDayEvents"]) {
        NSArray *indexPaths = [_collectionView indexPathsForSelectedItems];
        NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
        
        //Check to see if this cell is for a day of the previous month
        if (indexPath.row+1 - firstWeekDay <= 0) {
            if (!_screenLocked) {
                //Offset month if a previous month's cell is clicked
                [self backMonthOffset:nil];
            }

            canSegue = NO;
        }
        //Check to see if this cell is for a day of the next month
        else if (indexPath.row+1 - firstWeekDay > [CalendarInfo getDaysOfMonth:_selectedMonth ofYear:_selectedYear]) {
            
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

-(void) loadEvents
{
    _monthLabel.text = [NSString stringWithFormat:@"%@ %ld", [CalendarInfo getMonthBarDateOfMonth:_selectedMonth], (long)_selectedYear];
    _viewingMonth = [MonthFactory getMonthOfEventsFromMonth:_selectedMonth andYear:_selectedYear];
    [_collectionView reloadData];
    [_activityIndicator stopAnimating];
}


-(void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}


- (UIViewController *)presentationController:(UIPresentationController *)controller
  viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
{
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller.presentedViewController];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                style: UIBarButtonItemStyleDone
                                                               target:self
                                                               action:@selector(dismiss)];
    navigationController.topViewController.navigationItem.rightBarButtonItem = btnDone;
    return navigationController;
}


- (IBAction)itemButtonClicked:(UIBarButtonItem *)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CategoryView"];
    vc.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = [vc popoverPresentationController];
    popover.barButtonItem = sender;
    popover.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [_collectionView reloadData];
}



@end