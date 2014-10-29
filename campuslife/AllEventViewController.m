//
//  AllEventViewController.m
//  campuslife
//
//  Created by Super Student on 10/12/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

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
}

@end

@implementation AllEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = 44;
    cal = [self.tabBarController.childViewControllers objectAtIndex:0];
    NSDate *todaysDate = [[NSDate alloc] init];
    currentMonth = [[[todaysDate description] substringWithRange:NSMakeRange(5, 2)] intValue];
    currentYear = [[[todaysDate description] substringWithRange:NSMakeRange(0, 5)] intValue];
    events = [MonthlyEvents getSharedInstance];
    stopLoading = NO;
    // prevents data from reloading when user comes back from Day_Event_ViewController
    wentToEvent = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    if(!wentToEvent){
        [cal rollbackEvents];
        sortedArray = (NSMutableArray *)[events getEventsStartingToday];
        [self.tableView reloadData];
        stopLoading = NO;
    
    } else {
        wentToEvent = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedRow = indexPath.row;
    [self performSegueWithIdentifier:@"allEventToEventDetailTable" sender:self];
}

-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"allEventToEventDetailTable"]) {
        wentToEvent = YES;
        EventDetailTableViewController *destViewController = (EventDetailTableViewController *)[segue destinationViewController];

        [destViewController setEvent:[sortedArray objectAtIndex:selectedRow]];
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
    //NSLog(@"%ld >= %ld is: %d", indexPath.row, [sortedArray count] - 10, a);
    
    NSInteger rowCount = [sortedArray count];
    if(indexPath.row >= (NSInteger)(rowCount * 0.8) && !stopLoading)
    {
        self.tableView.scrollEnabled = NO;
        [self loadEventsForNextMonth];
        [self.tableView reloadData];
        self.tableView.scrollEnabled = YES;
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
        
        eventTimeLbl.text = [NSString stringWithFormat:@"%@ to %@",startTime, endTime];
        
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

-(void)loadEventsForNextMonth
{
    [self incrementCurrentMonth];
    [cal loadEventsForMonth:currentMonth andYear:currentYear];
    
    NSArray *newEvents = [events getEventsForCurrentMonth: 1];
    
    if([newEvents count] == 0) {
        stopLoading = YES;
    }
    
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


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
