//
//  AllEventViewController.m
//  campuslife
//
//  Created by Super Student on 10/12/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//1

#import "AllEventViewController.h"
#import "EventDetailTableViewController.h"
#import "CalendarViewController.h"
#import "CalendarInfo.h"
#import "Preferences.h"
#import "MonthFactory.h"
#import "MonthOfEvents.h"
#import "LCSCEvent.h"

@interface AllEventViewController ()
{
    NSMutableArray *displayedEvents;
    NSMutableArray *sortedArray;
    //NSInteger currentMonth;
    //NSInteger currentYear;
    BOOL wentToEvent;
    Preferences *preferences;
}

@end

@implementation AllEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    // prevents data from unnecessarily reloading when user comes back from Day_Event_ViewController
    wentToEvent = NO;
}


-(void)loadAllData
{
    sortedArray = [[NSMutableArray alloc] init];
    preferences = [Preferences getSharedInstance];
    NSLog(@"Starting loadAllEvents...\n");
    [self loadAllEvents];
    NSLog(@"Done");
    displayedEvents = [[NSMutableArray alloc] init];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(!wentToEvent){
        [displayedEvents removeAllObjects];
        [self removeCancelledEvents];
        [self.tableView reloadData];
    } else {
        wentToEvent = NO;
    }
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


// TODO: Make the LCSCEvent class return its NSDictionary representation
// Since the EventDetailTableViewController is used by the calendar and the list view
// So it can't have the LCSCEvent class integrated yet
-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"allEventToEventDetailTable"]) {
    
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        wentToEvent = YES;
        //Instantiate your next view controller!
        EventDetailTableViewController *destViewController = (EventDetailTableViewController *)[segue destinationViewController];
        
        [destViewController setEvent:[displayedEvents objectAtIndex:indexPath.row]];
    }
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
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *dayLbl = (UILabel *)[cell viewWithTag:20];
    UILabel *eventDetailLbl = (UILabel *)[cell viewWithTag:22];
    UILabel *eventTimeLbl = (UILabel *)[cell viewWithTag:24];
    UIImageView *image = (UIImageView *)[cell viewWithTag:10];
    LCSCEvent *myEvent = [displayedEvents objectAtIndex:indexPath.row];
    
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
    
    eventDetailLbl.text = [myEvent getSummary];
    
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







@end

