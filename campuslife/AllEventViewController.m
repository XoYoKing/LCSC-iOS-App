//
//  AllEventViewController.m
//  campuslife
//
//  Created by Super Student on 10/12/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//1

#import "AllEventViewController.h"
#import "EventDetailViewController.h"
#import "CalendarViewController.h"
#import "CalendarInfo.h"
#import "Preferences.h"
#import "MonthFactory.h"
#import "MonthOfEvents.h"
#import "LCSCEvent.h"
#import "SWRevealViewController.h"
#import "AllEventCell.h"


@interface DaySection : NSObject
-(id)initWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year events:(NSArray *)events;
-(LCSCEvent *)getEventAtIndex:(NSInteger)index;

@property (strong, nonatomic, readonly) NSString *sectionHeader;
@property (strong, nonatomic, readonly) NSArray *eventsInDay;
@end

@implementation DaySection

-(id)initWithDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year events:(NSArray *)events
{
    _eventsInDay = [[NSArray alloc] initWithArray:events];
    _sectionHeader = [NSString stringWithFormat:@"%@ %ld, %ld", [CalendarInfo getMonthBarDateOfMonth:month], day, year];
    return self;
    
}
-(LCSCEvent *)getEventAtIndex:(NSInteger)index
{
    return [_eventsInDay objectAtIndex:index];
}

@end


@interface AllEventViewController ()
{
    NSMutableArray *loadedMonths;
    NSMutableArray *daySections;
    Preferences *preferences;
    NSIndexPath *selectedIndex;
    }
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation AllEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = nil;
    preferences = [Preferences getSharedInstance];
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    [self loadMonths];
    self.tableView.rowHeight = 44;
}


-(void)loadDaySections
{
    daySections = [[NSMutableArray alloc] init];
    
    NSInteger today = [CalendarInfo getCurrentDay];
    NSInteger thisMonth = [CalendarInfo getCurrentMonth];
    NSInteger thisYear = [CalendarInfo getCurrentYear];
    for(MonthOfEvents *curMonthOfEvents in loadedMonths) {
        
        NSInteger curDay = 1;
        if(curMonthOfEvents.month == thisMonth && curMonthOfEvents.year == thisYear) {
            curDay = today;
        }
        for(; curDay < [curMonthOfEvents daysInMonth]; curDay++) {
            NSArray *eventsInDay = [curMonthOfEvents getEventsForDay:curDay];
            NSArray *filteredEvents = [self filterEvents:eventsInDay];
            if([filteredEvents count] > 0) {
                DaySection *daySect = [[DaySection alloc] initWithDay:curDay
                                                                month:curMonthOfEvents.month
                                                                 year:curMonthOfEvents.year
                                                               events:filteredEvents];
                [daySections addObject:daySect];
            }
        }
    }
}


-(NSArray *)filterEvents:(NSArray *)events
{
    NSMutableArray *filteredEvents = [[NSMutableArray alloc] init];
    for(LCSCEvent *event in events) {
        NSString *categoryName = [event getCategory];
        if([preferences getPreference:categoryName]) {
            [filteredEvents addObject:event];
        }
    }
    return (NSArray *)filteredEvents;
}


-(void)loadMonths
{
    loadedMonths = [[NSMutableArray alloc] init];
    NSInteger currentMonth = [CalendarInfo getCurrentMonth];
    NSInteger currentYear = [CalendarInfo getCurrentYear];
    
    NSInteger monthsAhead = 6;
    NSInteger endMonth = (currentYear * 12 + currentMonth + monthsAhead) % 12;
    NSInteger endYear = (currentYear * 12 + currentMonth + monthsAhead) / 12;
    NSArray *months = [MonthFactory getMonthOfEventsFromMonth:currentMonth andYear:currentYear
                                                      toMonth:endMonth andYear:endYear];
    for(MonthOfEvents *month in months) {
        [loadedMonths addObject:month];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadDaySections];
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [daySections count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[daySections objectAtIndex:section] sectionHeader];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    DaySection *daySect = [daySections objectAtIndex:section];
    return [daySect.eventsInDay count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EventCell";
    
    AllEventCell *cell = (AllEventCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                              forIndexPath:indexPath];
    UILabel *eventSummaryLbl = cell.titleLabel;
    UILabel *eventTimeLbl = cell.timeLabel;
    UIImageView *image = cell.dotImageView;
    LCSCEvent *myEvent = [[daySections objectAtIndex:indexPath.section] getEventAtIndex:indexPath.row];
    [cell setEvent:myEvent];

    if ([myEvent isAllDay])
    {
        eventTimeLbl.text = @"All Day Event";
    }
    else
    {
        NSString *eventStart = [myEvent getStartTimestamp];
        NSRange fiveToTen = NSMakeRange(5, 5);
        NSString *datePart = [eventStart substringWithRange:fiveToTen];
        
        datePart = [datePart stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        
        NSRange zeroToFour = NSMakeRange(0, 4);
        
        datePart = [datePart stringByAppendingString:@"/"];
        datePart = [datePart stringByAppendingString:[eventStart substringWithRange:zeroToFour]];
        
        NSRange elevenToSixteenStart = NSMakeRange(11, 5);
        NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
        startTime = [self twentyFourToTwelve:startTime];
        
        NSString *eventEnd = [myEvent getEndTimestamp];
        NSString *datePart2 = [eventEnd substringWithRange:fiveToTen];
        
        datePart2 = [datePart2 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        
        datePart2 = [datePart2 stringByAppendingString:@"/"];
        datePart2 = [datePart2 stringByAppendingString:[eventEnd substringWithRange:zeroToFour]];
        
        NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
        NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
        endTime = [self twentyFourToTwelve:endTime];
        
        eventTimeLbl.text = [NSString stringWithFormat:@"%@ - %@",startTime, endTime];
    }
    
    NSString *category = [myEvent getCategory];
    
    if ([category isEqualToString:@"Entertainment"])
    {
        [image setImage:[UIImage imageNamed:@"dotEntertainment.png"]];
    }
    else if ([category isEqualToString:@"Academics"])
    {
        [image setImage:[UIImage imageNamed:@"dotAcademics.png"]];
    }
    else if ([category isEqualToString:@"Student Activities"])
    {
        [image setImage:[UIImage imageNamed:@"dotActivities.png"]];
    }
    else if ([category isEqualToString:@"Residence Life"])
    {
        [image setImage:[UIImage imageNamed:@"dotResidence.png"]];
    }
    else if ([category isEqualToString:@"Warrior Athletics"])
    {
        [image setImage:[UIImage imageNamed:@"dotAthletics.png"]];
    }
    else if ([category isEqualToString:@"Campus Rec"])
    {
        [image setImage:[UIImage imageNamed:@"dotCampusRec.png"]];
    }
    
    eventSummaryLbl.text = [myEvent getSummary];
    if([selectedIndex isEqual:indexPath]) {
        [cell loadDescription];
    } else {
        [cell hideDescription];
    }
    return cell;
}


// TODO: Put this in the CalendarInfo class
- (NSString *)twentyFourToTwelve:(NSString *)time
{
    NSRange stringHourRange = NSMakeRange(0, 2);
    NSString *stringHour = [time substringWithRange:stringHourRange];
    int hourInt = [stringHour intValue];
    
    NSRange stringMinRange = NSMakeRange(2, 3);
    NSString *restOfString = [time substringWithRange:stringMinRange];
    
    
    if (hourInt == 0)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", 12, restOfString];
    }
    
    else if(hourInt < 12)
    {
        time = [NSString stringWithFormat:@"%d%@ AM", hourInt, restOfString];
    }
    
    else if (hourInt == 12)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", 12, restOfString];
    }
    
    else if (hourInt >= 13)
    {
        time = [NSString stringWithFormat:@"%d%@ PM", hourInt - 12, restOfString];
    }
    
    return time;
}


-(void)dismiss{
    [self loadDaySections];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)updateData:(NSNotification *)notification
{
    // if a cell is expanded and its category is deselected, we need to set selectedIndex properly
    if(selectedIndex != nil) {
        LCSCEvent *selectedEvent = [[daySections objectAtIndex:selectedIndex.section] getEventAtIndex:selectedIndex.row];
        if([[self filterEvents:@[selectedEvent]] count] == 0) {
            selectedIndex = nil;
        }
    }
    [self loadDaySections];
    [self.tableView reloadData];
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
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(updateData:)
     name:@"CategoryUpdatedNotification"
     object:vc];

    UIPopoverPresentationController *popover = [vc popoverPresentationController];
    popover.barButtonItem = sender;
    popover.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}


- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *cellsToReload = [[NSMutableArray alloc] init];
    [cellsToReload addObject:indexPath];
    // User is selecting a cell for the first time
    if(selectedIndex == nil) {
        selectedIndex = [NSIndexPath indexPathForRow:indexPath.row
                                         inSection:indexPath.section];
    }
    
    // user selected same cell again
    else if([selectedIndex isEqual:indexPath]) {
        selectedIndex = nil;
    }
    
    // user selected a new cell while another was selected
    else {
        NSIndexPath *prevPath = [selectedIndex copy];
        selectedIndex = [NSIndexPath indexPathForRow:indexPath.row
                                            inSection:indexPath.section];
        [cellsToReload addObject:prevPath];
    }
    [tableView reloadRowsAtIndexPaths:cellsToReload
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([selectedIndex isEqual:indexPath]) {
        return [AllEventCell ExpandedHeight];
    } else {
        return [AllEventCell DefaultHeight];
    }
}


@end

