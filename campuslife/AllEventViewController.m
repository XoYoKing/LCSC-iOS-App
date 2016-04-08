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

@interface AllEventViewController ()
{
    NSMutableArray *displayedEvents;
    NSMutableArray *sortedArray;
    //NSInteger currentMonth;
    //NSInteger currentYear;
    BOOL wentToEvent;
    Preferences *preferences;
    NSIndexPath *selectedIndex;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation AllEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = nil;
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    [self loadAllData];
    self.tableView.rowHeight = 44;
}


-(void)loadAllData
{
    sortedArray = [[NSMutableArray alloc] init];
    preferences = [Preferences getSharedInstance];
    [self loadAllEvents];
    displayedEvents = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [displayedEvents removeAllObjects];
    [self removeCancelledEvents];
    [self.tableView reloadData];
}


-(void)removeCancelledEvents
{
    for(int i = 0; i < [sortedArray count]; ++i) {
        LCSCEvent *event = sortedArray[i];
        NSString *categoryName = [event getCategory];
        for (NSString *name in [CalendarInfo getCategoryNames])
        {
            if ([categoryName isEqualToString:name] && ([preferences getPreference:categoryName] == YES)) {
                [displayedEvents addObject:sortedArray[i]];
            }
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [displayedEvents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"EventCell";
    
    AllEventCell *cell = (AllEventCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                                              forIndexPath:indexPath];
    UILabel *dayLbl = cell.dateLabel;
    UILabel *eventSummaryLbl = cell.titleLabel;
    UILabel *eventTimeLbl = cell.timeLabel;
    UIImageView *image = cell.dotImageView;
    LCSCEvent *myEvent = [displayedEvents objectAtIndex:indexPath.row];
    [cell setEvent:myEvent];

    if ([myEvent isAllDay])
    {
        eventTimeLbl.text = @"All Day Event";
        NSString *monthAbr = [self getMonthAbbreviation:[myEvent getStartMonth]];
        NSInteger dayNum = [myEvent getStartDay];
        dayLbl.text = [NSString stringWithFormat:@"%@ %d", monthAbr, (int)dayNum];
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
        
        NSString *monthAbr = [self getMonthAbbreviation:[myEvent getStartMonth]];
        NSInteger dayNum = [myEvent getStartDay];
        dayLbl.text = [NSString stringWithFormat:@"%@ %d", monthAbr, (int)dayNum];
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


-(void)loadAllEvents
{
    NSInteger currentMonth = [CalendarInfo getCurrentMonth];
    NSInteger currentYear = [CalendarInfo getCurrentYear];
    NSInteger currentDay = [CalendarInfo getCurrentDay];
    
    NSInteger monthsAhead = 6;
    NSInteger endMonth = (currentYear * 12 + currentMonth + monthsAhead) % 12;
    NSInteger endYear = (currentYear * 12 + currentMonth + monthsAhead) / 12;
    NSArray *months = [MonthFactory getMonthOfEventsFromMonth:currentMonth andYear:currentYear
                                                      toMonth:endMonth andYear:endYear];
    for(MonthOfEvents *month in months) {
        NSInteger curMonthDay = 1;
        for(NSArray *day in month) {
            if([month getMonth] == currentMonth && [month getYear] == currentYear) {
                if(curMonthDay >= currentDay) {
                    [sortedArray addObjectsFromArray:day];
                }
            }
            else {
                [sortedArray addObjectsFromArray:day];
            }
            curMonthDay++;
        }
    }
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


-(NSString *)getMonthAbbreviation:(NSInteger)monthNumber
{
    NSString *monthAbr;
    switch(monthNumber)
    {
        case 1:
            monthAbr = @"Jan";
            break;
            
        case 2:
            monthAbr = @"Feb";
            break;
            
        case 3:
            monthAbr = @"Mar";
            break;
            
        case 4:
            monthAbr = @"Apr";
            break;
            
        case 5:
            monthAbr = @"May";
            break;
            
        case 6:
            monthAbr = @"June";
            break;
            
        case 7:
            monthAbr = @"July";
            break;
            
        case 8:
            monthAbr = @"Aug";
            break;
            
        case 9:
            monthAbr = @"Sept";
            break;
            
        case 10:
            monthAbr = @"Oct";
            break;
            
        case 11:
            monthAbr = @"Nov";
            break;
            
        case 12:
            monthAbr = @"Dec";
            break;
    }
    
    return monthAbr;
}


-(void)dismiss{
    [displayedEvents removeAllObjects];
    [self removeCancelledEvents];
    [self.tableView reloadData];
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
    selectedIndex = nil;
    [displayedEvents removeAllObjects];
    [self removeCancelledEvents];
    [self.tableView reloadData];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row: %ld\nCol: %ld", (long)selectedIndex.row, (long)selectedIndex.section);
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

