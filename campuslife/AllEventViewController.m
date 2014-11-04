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

@interface AllEventViewController ()
{
    MonthlyEvents *events;
    NSMutableArray *sortedArray;
    NSInteger selectedRow;
    CalendarViewController *cal;
    NSInteger currentMonth;
    NSInteger currentYear;
    // Clayton Merge
    //BOOL hasLoadedOnce;
    //int numberOfLoads;
    BOOL stopLoading;
    BOOL wentToEvent;
    int noEventsInMonthCount;
}

@end

@implementation AllEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    UINavigationController *navCont = [self.tabBarController.childViewControllers objectAtIndex:0];
    cal = [navCont.childViewControllers objectAtIndex:0];
    NSDate *todaysDate = [[NSDate alloc] init];
    currentMonth = [[[todaysDate description] substringWithRange:NSMakeRange(5, 2)] intValue];
    currentYear = [[[todaysDate description] substringWithRange:NSMakeRange(0, 5)] intValue];
    events = [MonthlyEvents getSharedInstance];
    stopLoading = NO;
    // prevents data from unnecessarily reloading when user comes back from Day_Event_ViewController
    wentToEvent = NO;
    noEventsInMonthCount = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    if(!wentToEvent){
        [cal rollbackEvents];
        NSDate *todaysDate = [[NSDate alloc] init];
        currentMonth = [[[todaysDate description] substringWithRange:NSMakeRange(5, 2)] intValue];
        currentYear = [[[todaysDate description] substringWithRange:NSMakeRange(0, 5)] intValue];
        sortedArray = (NSMutableArray *)[events getEventsStartingToday];
        [self incrementCurrentMonth];
        [self loadEventsForNextSixMonths];
        // events won't load for next month if nothing was loaded for this month
        stopLoading = NO;
        [self.tableView reloadData];
    
    } else {
        wentToEvent = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"allEventToEventDetailTable" sender:self];
}*/

/*
-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"allEventToEventDetailTable"]) {
        wentToEvent = YES;
        EventDetailTableViewController *destViewController = (EventDetailTableViewController *)[segue destinationViewController];

        [destViewController setEvent:[sortedArray objectAtIndex:selectedRow]];
    }
}
 */

-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"allEventToEventDetailTable"]) {
    
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        wentToEvent = YES;
        //Instantiate your next view controller!
        EventDetailTableViewController *destViewController = (EventDetailTableViewController *)[segue destinationViewController];
        
        [destViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [sortedArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //BOOL a = indexPath.row >= [sortedArray count] - 10;

    
    NSInteger rowCount = [sortedArray count];
    if(indexPath.row >= (NSInteger)(rowCount * 0.8) && !stopLoading)
    {
        //self.tableView.scrollEnabled = NO;
        //[self loadEventsForNextMonth];
        //[self.tableView reloadData];
        //self.tableView.scrollEnabled = YES;
    }
    
    static NSString *CellIdentifier = @"EventCell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    UILabel *dayLbl = (UILabel *)[cell viewWithTag:20];
    UILabel *eventDetailLbl = (UILabel *)[cell viewWithTag:22];
    UILabel *eventTimeLbl = (UILabel *)[cell viewWithTag:24];
    UIImageView *image = (UIImageView *)[cell viewWithTag:10];
    NSDictionary *eventTime = [sortedArray objectAtIndex:indexPath.row];
    
    
    
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
}

-(void)loadEventsForNextSixMonths
{
    for(int i = 0; i < 5; ++i) {
        [self loadEventsForNextMonth];
    }
}

-(void)loadEventsForNextMonth
{
    [self incrementCurrentMonth];
    [events offsetMonth:1];
    [cal loadEventsForMonth:currentMonth andYear:currentYear];
    
    NSArray *newEvents = [events getEventsForCurrentMonth: 1];
    //NSLog([newEvents description]);
    [sortedArray addObjectsFromArray:newEvents];
    
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

-(void) loadEventsForMonth:(NSInteger)month onYear:(NSInteger)year
{
    [events setMonth:month];
    [events setYear:year];
}

- (void) parseJSON:(NSData *)JSONAsData onMonth:(NSInteger)month1 onYear:(NSInteger)year1 {
    NSError *error = nil;
    
    // Get the JSON data as a dictionary.
    // Josh NOTE
    NSDictionary *eventsInfoDict = [NSJSONSerialization JSONObjectWithData:JSONAsData options:NSJSONReadingMutableContainers error:&error];
    
    if (error) {
        // This is the case that an error occured during converting JSON data to dictionary.
        // Simply log the error description.
        
    }
    else{
        //Get the events as an array
        
        NSMutableArray *oldEventsInfo = [eventsInfoDict valueForKeyPath:@"items"];
        
        
        if (oldEventsInfo == nil) {
            oldEventsInfo = [[NSMutableArray alloc] init];
        }
        
        NSString *category;
        
        for (NSString *name in [events getCategoryNames])
        {
            if ([cal getIndexOfSubstringInString:name :[eventsInfoDict valueForKeyPath:@"summary"]] != -1) {
                category = name;
                
            }
            else{
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
    
    /*
    if (![_events getCalendarJsonReceivedForMonth:_curArrayId :category])
    {
        
        
        [_events setCalendarJsonReceivedForMonth:_curArrayId :category];
        if (_curArrayId == 1)
        {
            _monthLabel.text = [NSString stringWithFormat:@"%@ %d", [_events getMonthBarDate], [_events getSelectedYear]];
            
        }
     */
        
        //int selectedMonth = month1 ;//[events getSelectedMonth] + (_curArrayId-1);
        //int selectedYear = [events getSelectedYear];
        int selectedYear = year1;
        int selectedMonth = month1;
        
        
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
            
            
            //Change to check string length???
            //Josh NOTE
            
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
                            //This then uses that day as an index and inserts the currentEvent into that indice's array.
                            //[events AppendEvent:day :currentEventInfo :_curArrayId];
                            [sortedArray addObject:currentEventInfo];
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
            
            
        }
    /*
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
            }*/
    }
}






@end
