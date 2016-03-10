//
//  Day_Event_ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Day_Event_ViewController.h"
#import "Preferences.h"
#import "EventDetailViewController.h"
#import "CalendarViewController.h"
#import "SWRevealViewController.h"


@interface Day_Event_ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic) BOOL didSegue;

@end




@implementation Day_Event_ViewController


/*
 *  Usefull for checking whether or not the view Loaded.
 *
 *  Only loads once.
 */
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    self.tableView.rowHeight = 44;
    //self.navigationItem.title = [NSString stringWithFormat:@"%@ %d, %d", [events getMonthBarDate], [events getSelectedDay], [events getSelectedYear]];
    
    //self.navigationController.navigationBar.topItem.title = @"";
    
    
    [self.tableView reloadData];
}


/*
 *  Request new information from day at index.
 */
-(void)viewDidAppear:(BOOL)animated
{
    _didSegue = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DayToDetail"]) {
        if (!_didSegue)
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            
            //Instantiate your next view controller!
            EventDetailViewController *destViewController = (EventDetailViewController *)[segue destinationViewController];
            
            [destViewController setEvent:[_dayEvents objectAtIndex:indexPath.row]];
        }
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dayEvents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    LCSCEvent *the_event = [_dayEvents objectAtIndex:indexPath.row];
    
    if ([the_event isAllDay])
    {
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = @"All Day Event";
    }
    else
    {
        NSString *eventStart = [the_event getStartTimestamp];
        NSRange elevenToSixteenStart = NSMakeRange(11, 5);
        NSString *startTime = [eventStart substringWithRange:elevenToSixteenStart];
        startTime = [self twentyFourToTwelve:startTime];
        
        NSString *eventEnd = [the_event getEndTimestamp];
        NSRange elevenToSixteenEnd = NSMakeRange(11, 5);
        NSString *endTime = [eventEnd substringWithRange:elevenToSixteenEnd];
        endTime = [self twentyFourToTwelve:endTime];
        
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = [NSString stringWithFormat:@"%@ \nto\n %@", startTime, endTime];
    }
    
    NSString *category = [the_event getCategory];
    
    if ([category isEqualToString:@"Entertainment"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotEntertainment.png"]];
    }
    else if ([category isEqualToString:@"Academics"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotAcademics.png"]];
    }
    else if ([category isEqualToString:@"Student Activities"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotActivities.png"]];
    }
    else if ([category isEqualToString:@"Residence Life"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotResidence.png"]];
    }
    else if ([category isEqualToString:@"Warrior Athletics"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotAthletics.png"]];
    }
    else if ([category isEqualToString:@"Campus Rec"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotCampusRec.png"]];
    }
    
    UILabel *summary = (UILabel *)[cell viewWithTag:22];
    NSString *summaryHold = [the_event getSummary];
    summaryHold = [summaryHold stringByReplacingOccurrencesOfString:@":" withString:@""];
    summary.text = summaryHold;
    
    return cell;
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

@end
