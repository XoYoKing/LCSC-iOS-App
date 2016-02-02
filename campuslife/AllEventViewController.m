//
//  AllEventViewController.m
//  campuslife
//
//  Created by Super Student on 10/12/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//1

#import "AllEventViewController.h"
#import "MonthlyEvents.h"
#import "EventDetailTableViewController.h"
#import "CalendarViewController.h"
#import "CalendarInfo.h"
#import "Preferences.h"

@interface AllEventViewController ()
{
    MonthlyEvents *events;
    NSMutableArray *displayedEvents;
    NSMutableArray *sortedArray;
    CalendarViewController *cal;
    NSInteger currentMonth;
    NSInteger currentYear;
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
    UINavigationController *navCont = [self.tabBarController.childViewControllers objectAtIndex:0];
    cal = [navCont.childViewControllers objectAtIndex:0];
    sortedArray = [[NSMutableArray alloc] init];
    NSDate *todaysDate = [[NSDate alloc] init];
    currentMonth = [[[todaysDate description] substringWithRange:NSMakeRange(5, 2)] intValue];
    currentYear = [[[todaysDate description] substringWithRange:NSMakeRange(0, 5)] intValue];
    events = [MonthlyEvents getAllEventsInstance];
    preferences = [Preferences getSharedInstance];
    [self loadAllEvents];
    displayedEvents = [[NSMutableArray alloc] init];

    [sortedArray sortUsingComparator: ^NSComparisonResult(id obj1, id obj2){
         return [self compareEvents:obj1 :obj2];
     }];
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
        NSString *categoryName = [sortedArray[i] objectForKey:@"category"];
        for (NSString *name in [[MonthlyEvents getSharedInstance] getCategoryNames])
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
    NSDictionary *eventTime = [displayedEvents objectAtIndex:indexPath.row];
    
    if ([[eventTime objectForKey:@"start"] objectForKey:@"dateTime"] == nil)
    {
        eventTimeLbl.text = @"All Day Event";
        NSString *date = [[eventTime objectForKey:@"start"] objectForKey:@"date"];
        NSInteger monthNum = [[date substringWithRange:NSMakeRange(5, 2)] integerValue];
        NSString *dayNum = [date substringWithRange:NSMakeRange(8, 2)];
        NSString *monthAbr = [self getMonthAbbreviation:monthNum];
        dayLbl.text = [NSString stringWithFormat:@"%@ %@", monthAbr, dayNum];
    }
    else
    {
        NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
        NSRange fiveToTen = NSMakeRange(5, 5);
        NSString *datePart = [eventStart substringWithRange:fiveToTen];
        
        datePart = [datePart stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        
        NSRange zeroToFour = NSMakeRange(0, 4);
        
        datePart = [datePart stringByAppendingString:@"/"];
        datePart = [datePart stringByAppendingString:[eventStart substringWithRange:zeroToFour]];
        
        NSRange elevenToSixteenStart = NSMakeRange(11, 5);
        NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
        startTime = [self twentyFourToTwelve:startTime];
        
        NSString *eventEnd = [[eventTime objectForKey:@"end"] objectForKey:@"dateTime"];
        NSString *datePart2 = [eventEnd substringWithRange:fiveToTen];
        
        datePart2 = [datePart2 stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        
        datePart2 = [datePart2 stringByAppendingString:@"/"];
        datePart2 = [datePart2 stringByAppendingString:[eventEnd substringWithRange:zeroToFour]];
        
        NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
        NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
        endTime = [self twentyFourToTwelve:endTime];
        
        eventTimeLbl.text = [NSString stringWithFormat:@"%@ - %@",startTime, endTime];
        
        NSInteger monthNum = [[datePart substringWithRange:NSMakeRange(0, 2)] integerValue];
        NSString *dayNum = [datePart substringWithRange:NSMakeRange(3, 2)];
        NSString *monthAbr = [self getMonthAbbreviation:monthNum];
        dayLbl.text = [NSString stringWithFormat:@"%@ %@", monthAbr, dayNum];
    }
    
    if ([[eventTime objectForKey:@"category"] isEqualToString:@"Entertainment"])
    {
        [image setImage:[UIImage imageNamed:@"dotEntertainment.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Academics"])
    {
        [image setImage:[UIImage imageNamed:@"dotAcademics.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Student Activities"])
    {
        [image setImage:[UIImage imageNamed:@"dotActivities.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Residence Life"])
    {
        [image setImage:[UIImage imageNamed:@"dotResidence.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Warrior Athletics"])
    {
        [image setImage:[UIImage imageNamed:@"dotAthletics.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Campus Rec"])
    {
        [image setImage:[UIImage imageNamed:@"dotCampusRec.png"]];
    }
    
    eventDetailLbl.text = [eventTime objectForKey:@"summary"];
    
    return cell;
}

-(NSComparisonResult)compareEvents:(NSMutableDictionary *)event1 :(NSMutableDictionary *)event2
{
    NSComparisonResult comp;
    int event1Year;
    int event1Month;
    int event1Day;
    int event1Hour;
    BOOL event1IsAllDay = ([[event1 objectForKey:@"start"] objectForKey:@"dateTime"] == nil);
    
    int event2Year;
    int event2Month;
    int event2Day;
    int event2Hour;
    BOOL event2IsAllDay = ([[event2 objectForKey:@"start"] objectForKey:@"dateTime"] == nil);
    
    if(!event1IsAllDay) {
        NSString *timestamp = [[event1 objectForKey:@"start"] objectForKey:@"dateTime"];
        event1Year = (int)[[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
        event1Month = (int)[[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
        event1Day = (int)[[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
        event1Hour = (int)[[timestamp substringWithRange:NSMakeRange(11, 2)] integerValue];
    
    } else {
        NSString *timestamp = [[event1 objectForKey:@"start"] objectForKey:@"date"];
        event1Year = (int)[[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
        event1Month = (int)[[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
        event1Day = (int)[[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
        event1Hour = 0;
    }
    
    if(!event2IsAllDay) {
        NSString *timestamp = [[event2 objectForKey:@"start"] objectForKey:@"dateTime"];
        event2Year = (int)[[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
        event2Month = (int)[[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
        event2Day = (int)[[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
        event2Hour = (int)[[timestamp substringWithRange:NSMakeRange(11, 2)] integerValue];
        
    } else {
        NSString *timestamp = [[event2 objectForKey:@"start"] objectForKey:@"date"];
        event2Year = (int)[[timestamp substringWithRange:NSMakeRange(0, 4)] integerValue];
        event2Month = (int)[[timestamp substringWithRange:NSMakeRange(5, 2)] integerValue];
        event2Day = (int)[[timestamp substringWithRange:NSMakeRange(8, 2)] integerValue];
        event2Hour = 0;
    }
    
    if(event1Year < event2Year) {
        comp = (NSComparisonResult )NSOrderedAscending;
    
    } else if(event1Year > event2Year) {
        comp = (NSComparisonResult )NSOrderedDescending;
    
    } else if(event1Month < event2Month) {
        comp = (NSComparisonResult )NSOrderedAscending;
    
    } else if(event1Month > event2Month) {
        comp = (NSComparisonResult )NSOrderedDescending;
        
    } else if(event1Day < event2Day) {
        comp = (NSComparisonResult )NSOrderedAscending;
    
    } else if(event1Day > event2Day) {
        comp = (NSComparisonResult )NSOrderedDescending;
    
    } else if(event1Hour < event2Hour) {
        comp = (NSComparisonResult )NSOrderedAscending;
    
    } else if(event1Hour > event2Hour) {
        comp = (NSComparisonResult )NSOrderedDescending;
    
    } else {
        comp = (NSComparisonResult )NSOrderedSame;
    }
    
    return comp;
}

-(void)incrementCurrentMonth
{
    ++currentMonth;
    if (currentMonth > 12){
        currentMonth = 1;
        currentYear++;
    }else if (currentMonth < 1){
        currentMonth = 12;
        currentYear--;
    }
    [events offsetMonth:1];
}

 
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


-(void)loadAllEvents
{
    for(int i = 0; i <= 5; i++) {
        [self incrementCurrentMonth];
    }
    
    int toMonth = (int)currentMonth;
    int toYear = (int)currentYear;
    int endDay = [events getDaysOfMonth:toMonth :toYear];
    
    int curMonth = (int)[CalendarInfo getCurrentMonth];
    int curYear = (int)[CalendarInfo getCurrentYear];
    int curDay = (int)[CalendarInfo getCurrentDay];
    NSString *curDayAsString;
    if(curDay < 10) {
        curDayAsString = [NSString stringWithFormat:@"0%d", curDay];
    
    } else {
        curDayAsString = [NSString stringWithFormat:@"%d", curDay];
    }
    
    for (NSString *name in [events getCategoryNames])
    {
        NSURL *url;
        NSString *calendarID = [[MonthlyEvents getSharedInstance] getCalIds][name];
        NSString *urlString;

        
        if(curMonth >= 10 && curMonth <= 12 && toMonth >= 10 && curMonth <= 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-0%d-%@T00:00:00-07:00&timeMax=%d-0%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,curYear,curMonth, curDayAsString,toYear,toMonth,endDay];
            
        } else if(curMonth >= 10 && curMonth <= 12 && toMonth < 10 && curMonth > 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-0%d-%@T00:00:00-07:00&timeMax=%d-%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,curYear,curMonth, curDayAsString,toYear,toMonth,endDay];
            
        } else if(curMonth < 10 && curMonth > 12 && toMonth >= 10 && curMonth <= 12) {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-%d-0%@T00:00:00-07:00&timeMax=%d-0%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,curYear,curMonth, curDayAsString,toYear,toMonth,endDay];
            
        } else {
            urlString = [NSString stringWithFormat:@"https://www.googleapis.com/calendar/v3/calendars/%@/events?maxResults=2500&timeMin=%d-%d-%@T00:00:00-07:00&timeMax=%d-%d-%dT11:59:59-07:00&singleEvents=true&key=AIzaSyASiprsGk5LMBn1eCRZbupcnC1RluJl_q0",calendarID,curYear,curMonth, curDayAsString,toYear,toMonth,endDay];
        }
        
 
        
        url = [NSURL URLWithString:urlString];
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (data != nil)
        {
            [self parseJSON:data];
        }
    }
}

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
        
        NSMutableArray *oldEventsInfo = [eventsInfoDict valueForKeyPath:@"items"];
        
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
                    int daysInMonth = [events getDaysOfMonth:monthHold :yearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){
                        int startyearHold = [[currentStartTime substringWithRange:NSMakeRange(0, 4)] intValue];
                        int startmonthHold = [[currentStartTime substringWithRange:NSMakeRange(5, 2)] intValue];
                        int amountOfStartDays = [events getDaysOfMonth:startmonthHold :startyearHold];
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
                            daysInMonth = [events getDaysOfMonth:monthHold :yearHold];
                            
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
                            //clayton spring break is broken in both code bases for all evetns and calendar
                            
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
                    
                    int daysInMonth = [events getDaysOfMonth:startmonthHold :startyearHold];
                    int amountOfDays = (EnddayHold-StartdayHold)+1;
                    if (amountOfDays < 0){
                        
                        int amountOfStartDays = [events getDaysOfMonth:startmonthHold :startyearHold];
                        amountOfDays = amountOfStartDays-StartdayHold+EnddayHold;
                    }
                    if (amountOfDays >1) {
                        int counter = 0;
                        NSDictionary *holdRecurEvent = holdDict[i];
                        int newDay = StartdayHold;
                        int newEndDay = newDay + 1;
                        int endMonthHold = startmonthHold;
                        int endYearHold = startyearHold;
                        int daysInEndMonth = [events getDaysOfMonth:endMonthHold :endYearHold];
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
                                daysInMonth = [events getDaysOfMonth:startmonthHold :startyearHold];
                            }
                            if(newEndDay > daysInEndMonth){
                                endMonthHold++;
                                if (endMonthHold > 12){
                                    endMonthHold = 1;
                                    endYearHold++;
                                }
                                newEndDay = 1;
                                daysInEndMonth = [events getDaysOfMonth:startmonthHold :startyearHold];
                                
                            }
                            NSString *SyearHold = [NSString stringWithFormat:@"%d",startyearHold];
                            NSString *sMonthHold = [[NSString alloc] init];
                            NSString *sDayHold = [[NSString alloc] init];
                            NSString *EyearHold = [NSString stringWithFormat:@"%d",endYearHold];
                            NSString *eMonthHold = [[NSString alloc] init];
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
        
        for (NSString *name in [events getCategoryNames])
        {
            if ([cal getIndexOfSubstringInString:name :[eventsInfoDict valueForKeyPath:@"summary"]] != -1) {
                category = name;
                
            }
        }
        //Convert the structure of the dictionaries in eventsInfo so that the dictionaries are compatible with the rest
        //  of the app.

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
        
        //[sortedArray addObjectsFromArray:eventsInfo];
            
        
        [events setCalendarJsonReceivedForMonth:1 :category];
  
        
        
        int selectedMonth = [events getSelectedMonth];
        int selectedYear = [events getSelectedYear];
        
        
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
                        endDay += [events getDaysOfMonth:month :startYear];
                        
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
                        endDay += [events getDaysOfMonth:month :startYear];
                        
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
                            endDay += [events getDaysOfMonth:month :year];
                            
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
                        endDay += [events getDaysOfMonth:month :startYear];
                        
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
                        endDay += [events getDaysOfMonth:month :startYear];
                        
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
                            
                            endDay += [events getDaysOfMonth:month :year];
                            
                            
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
            int wrappedDays = endDay-[events getDaysOfMonth:startMonth :startYear];
            

            
            //The e variable isn't being set properly. So fix it!
            
            int s = 0;
            int e = 0;
            
            //The outer loop loops through the reocurrences.
            for (int rep=0; rep<repeat; rep++) {
                BOOL iterateOverDays = YES;
                
                //Are we dealing with a monthly repeat?
                if (freq >= 28 && freq <= 31) {
                    freq = [events getDaysOfMonth:startMonth :startYear];
                    
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
                        if (endDay > [events getDaysOfMonth:startMonth :startYear]) {
                            
                            e = [events getDaysOfMonth:startMonth :startYear];
                            
                        }
                        else {
                            e = endDay;
                        }
                    }
                    //Check if the startMonth is the previous month and the endDay will roll over into the next month.
                    else if (startMonth + 1 == selectedMonth && endDay > [events getDaysOfMonth:startMonth :startYear]) {
                        
                        //We don't care about the days in the previous month, only that
                        //  the rolled over days are going to be in the selected month.
                        s = 1;
                        
                        //endDay is for sure going to be above the daysInMonth.
                        e = endDay%[events getDaysOfMonth:startMonth :startYear];
                        
                    }
                    else {
                        //We'll skip this iterating, because we won't add anything.
                        iterateOverDays = NO;
                    }
                }
                else if (startYear == selectedYear-1
                         && startMonth == 12
                         && endDay > [events getDaysOfMonth:startMonth :startYear]) {
                    
                    //We don't care about the days in the previous month, only that
                    //  the rolled over days are going to be in the selected month.
                    s = 1;
                    
                    //endDay is for sure going to be above the daysInMonth.
                    e = endDay%[events getDaysOfMonth:startMonth :startYear];
                    
                }
                else {
                    //We'll skip this iterating, because we won't add anything.
                    iterateOverDays = NO;
                }
                if (iterateOverDays) {
                    //Add events for the startday all the way up to the end day.
                    for (int day=s; day<e+1; day++) {
                        if (day != 0) {

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
                    if (startDay%[events getDaysOfMonth:startMonth :startYear] < startDay) {
                        
                        //Then we mod the startDay to get the day of the next month it will be on.
                        startDay = startDay-[events getDaysOfMonth:startMonth :startYear];
                        
                        endDay = endDay-[events getDaysOfMonth:startMonth :startYear];
                        
                        startMonth += 1;
                        
                        //Check to see if we transitioned to a new year.
                        if (startMonth > 12) {
                            startMonth = 1;
                            startYear += 1;
                        }
                        if (wrappedDays > 0) {
                            if (startMonth != 1) {
                                endDay += [events getDaysOfMonth:startMonth :startYear] - [events getDaysOfMonth:startMonth-1 :startYear];
                                
                            }
                            else {
                                endDay += [events getDaysOfMonth:startMonth :startYear] - [events getDaysOfMonth:12 :startYear-1];
                                
                            }
                        }
                    }
                    else
                    {
                        nextDateUpdated = YES;
                    }
                }
            }
            
            // for now, each currentEventInfo is just added to the sortedArray at the end of each iteration
            [sortedArray addObject:currentEventInfo];
        }
    }
}




@end

