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
#import "DayEventCell.h"

@interface Day_Event_ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
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
    _selectedIndex = nil;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    /*
    if ([segue.identifier isEqualToString:@"DayToDetail"]) {
        if (!_didSegue)
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            
            //Instantiate your next view controller!
            EventDetailViewController *destViewController = (EventDetailViewController *)[segue destinationViewController];
            
            [destViewController setEvent:[_dayEvents objectAtIndex:indexPath.row]];
        }
    }
     */
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
    
    DayEventCell *cell = (DayEventCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    LCSCEvent *the_event = [_dayEvents objectAtIndex:indexPath.row];
    [cell setEvent:the_event];

    if ([the_event isAllDay])
    {
        cell.eventTimeLabel.text = @"All Day Event";
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
        
        cell.eventTimeLabel.text = [NSString stringWithFormat:@"%@ \nto\n %@", startTime, endTime];
    }
    
    NSString *category = [the_event getCategory];
    NSString *dotFile;
    if ([category isEqualToString:@"Entertainment"])
    {
        dotFile = @"dotEntertainment.png";
    }
    else if ([category isEqualToString:@"Academics"])
    {
        dotFile = @"dotAcademics.png";
    }
    else if ([category isEqualToString:@"Student Activities"])
    {
        dotFile = @"dotActivities.png";
    }
    else if ([category isEqualToString:@"Residence Life"])
    {
        dotFile = @"dotResidence.png";
    }
    else if ([category isEqualToString:@"Warrior Athletics"])
    {
        dotFile = @"dotAthletics.png";
    }
    else if ([category isEqualToString:@"Campus Rec"])
    {
        dotFile = @"dotCampusRec.png";
    }
    
    [cell.eventDotImageView setImage:[UIImage imageNamed:dotFile]];
    
    NSString *summaryHold = [the_event getSummary];
    summaryHold = [summaryHold stringByReplacingOccurrencesOfString:@":" withString:@""];
    cell.summaryLabel.text = summaryHold;
    
    if([_selectedIndex isEqual:indexPath]) {
        [cell loadDescription];
    
    } else {
        [cell hideDescription];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableArray *cellsToReload = [[NSMutableArray alloc] init];
    [cellsToReload addObject:indexPath];
    
    // User is selecting a cell for the first time
    if(_selectedIndex == nil) {
        _selectedIndex = [NSIndexPath indexPathForRow:indexPath.row
                                           inSection:indexPath.section];    }
    
    // user selected same cell again
    else if([_selectedIndex isEqual:indexPath]) {
        _selectedIndex = nil;
    }
    
    // user selected a new cell while another was selected
    else {
        NSIndexPath *prevPath = [_selectedIndex copy];
        _selectedIndex = [NSIndexPath indexPathForRow:indexPath.row
                                           inSection:indexPath.section];        [cellsToReload addObject:prevPath];
    }
    
    [tableView reloadRowsAtIndexPaths:cellsToReload
                     withRowAnimation:UITableViewRowAnimationAutomatic];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_selectedIndex isEqual:indexPath]) {
        return [DayEventCell ExpandedHeight];
    } else {
        return [DayEventCell DefaultHeight];
    }
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
