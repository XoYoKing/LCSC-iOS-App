//
//  Day_Event_ViewController.m
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import "Day_Event_ViewController.h"
#import "MonthlyEvents.h"
#import "Preferences.h"
#import "EventDetailTableViewController.h"
#import "CalendarViewController.h"



@interface Day_Event_ViewController ()
{
    
    MonthlyEvents *events;
    
    NSMutableArray *sortedArray;
    
}

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
    self.tableView.rowHeight = 44;
    
    [super viewDidLoad];
    
    events = [MonthlyEvents getSharedInstance];
    
    [self setDay:[events getSelectedDay]];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %d, %d", [events getMonthBarDate], [events getSelectedDay], [events getSelectedYear]];
    
    sortedArray = [self eventSorter:[events getEventsForDay:_day]];
    
    [self.tableView reloadData];
}




/*
 *  Request new information from day at index.
 */
-(void)viewDidAppear:(BOOL)animated
{

    _didSegue = NO;
}




/*
 *  Possibly useless?
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}





- (NSMutableArray *)eventSorter:(NSArray *)unsorted
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    
    [newArray addObjectsFromArray:unsorted];
    
    if ([[events getEventsForDay:_day] count]>=1)
    {

        
        Preferences *preferences = [Preferences getSharedInstance];
        
        int currentPos = 0;
        
        while (currentPos < [newArray count])
        {
            NSString *categoryName = [newArray[currentPos] objectForKey:@"category"];

            
            BOOL removedSomething = NO;
            for (NSString *name in [[MonthlyEvents getSharedInstance] getCategoryNames])
            {
                if ([categoryName isEqualToString:name] && ([preferences getPreference:categoryName] == NO))
                {
        
                    
                    [newArray removeObjectAtIndex:currentPos];
                    
                    removedSomething = YES;
                }
            }
            
            if(!removedSomething)
            {
                currentPos++;
            }
        }
        
        
        

        
        
        
        if ([newArray count] > 1)
        {
       
            
            int currentPos = 0;
            
            BOOL finished = FALSE;
            
            while(!finished)
            {
            
                
                int lowestItem = currentPos;
                
                for (int i = currentPos + 1; i < [newArray count]; i++)
                {
                 
                    
                    NSRange startHr1 = NSMakeRange(11, 2);
                    NSRange startMn1 = NSMakeRange(14, 2);
                    NSString *startHrStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr1];
                    NSString *startMnStr1 = [[[newArray[lowestItem] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn1];
                    NSString *startTime1 =[startHrStr1 stringByAppendingString:startMnStr1];
                    int start1 = [startTime1 intValue];
                
                    
                    NSRange startHr2 = NSMakeRange(11, 2);
                    NSRange startMn2 = NSMakeRange(14, 2);
                    NSString *startHrStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startHr2];
                    NSString *startMnStr2 = [[[newArray[i] objectForKey:@"start"] objectForKey:@"dateTime"] substringWithRange:startMn2];
                    NSString *startTime2 =[startHrStr2 stringByAppendingString:startMnStr2];
                    int start2 = [startTime2 intValue];
               
                    
                    if (start1 > start2)
                    {
                      
                        
                        lowestItem = i;
                    }
                    else if (start1 == start2)
                    {

                        
                        NSRange endHr1 = NSMakeRange(11, 2);
                        NSRange endMn1 = NSMakeRange(14, 2);
                        NSString *endHrStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr1];
                        NSString *endMnStr1 = [[[newArray[lowestItem] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn1];
                        NSString *endTime1 =[endHrStr1 stringByAppendingString:endMnStr1];
                        int end1 = [endTime1 intValue];
        
                        
                        NSRange endHr2 = NSMakeRange(11, 2);
                        NSRange endMn2 = NSMakeRange(14, 2);
                        NSString *endHrStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endHr2];
                        NSString *endMnStr2 = [[[newArray[i] objectForKey:@"end"] objectForKey:@"dateTime"] substringWithRange:endMn2];
                        NSString *endTime2 =[endHrStr2 stringByAppendingString:endMnStr2];
                        int end2 = [endTime2 intValue];

                        
                        if (end1 > end2)
                        {
        
                            
                            lowestItem = i;
                        }
                    }
                    
                    
                }
                
                if (lowestItem != currentPos)
                {
                    
                    NSDictionary *temp = newArray[currentPos];
                    
                    newArray[currentPos] = newArray[lowestItem];
                    
                    newArray[lowestItem] = temp;
            
                    
                    currentPos += 1;
                }
                else
                {
                    currentPos += 1;
                }
                
                if (currentPos == [newArray count] - 1)
                {
                    finished = TRUE;
                    
                }
            }
        }
    }

    
    return newArray;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    EventDetailViewController *detailViewController;
    if (IDIOM != IPAD) {
        detailViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDetail"];
        
        [detailViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
        [self presentPopupViewController:detailViewController animationType:0];
        detailViewController.view.superview.bounds=CGRectMake(0.0, 0.0, 240.0, 408.0);
        ///detailViewController.view.superview.center=detailViewController.view.center;
        detailViewController.view.superview.clipsToBounds=YES;
        
    }
    
    else {
        detailViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateViewControllerWithIdentifier:@"eventDetail"];
        
        [detailViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
        [self presentPopupViewController:detailViewController animationType:0];
        detailViewController.view.superview.bounds=CGRectMake(0.0, 0.0, 300.0, 500.0);
        ///detailViewController.view.superview.center=detailViewController.view.center;
        detailViewController.view.superview.clipsToBounds=YES;
    }*/
}


-(void) prepareForSegue:(UIStoryboardPopoverSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DayToDetail"]) {
        if (!_didSegue)
        {
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            
            //Instantiate your next view controller!
            EventDetailTableViewController *destViewController = (EventDetailTableViewController *)[segue destinationViewController];
            
            [destViewController setEvent:[sortedArray objectAtIndex:indexPath.row]];
        }
    }
}


// Useless comment!
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sortedArray count];
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EventCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    NSDictionary *eventTime = [sortedArray objectAtIndex:indexPath.row];
    

    
    if ([[eventTime objectForKey:@"start"] objectForKey:@"dateTime"] == nil)
    {
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = @"All Day Event";
    }
    else
    {
        NSString *eventStart = [[eventTime objectForKey:@"start"] objectForKey:@"dateTime"];
        NSString *startTime = [eventStart substringWithRange:NSMakeRange(11, 5)];
        startTime = [self twentyFourToTwelve:startTime];
        UILabel *time = (UILabel *)[cell viewWithTag:20];
        time.text = [NSString stringWithFormat:@"%@", startTime];
    }
    
    if ([[eventTime objectForKey:@"category"] isEqualToString:@"Entertainment"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotEntertainment.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Academics"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotAcademics.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Student Activities"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotActivities.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Residence Life"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotResidence.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Warrior Athletics"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotAthletics.png"]];
    }
    else if ([[eventTime objectForKey:@"category"] isEqualToString:@"Campus Rec"])
    {
        UIImageView *image = (UIImageView *)[cell viewWithTag:21];
        [image setImage:[UIImage imageNamed:@"dotCampusRec.png"]];
    }
    
    UILabel *summary = (UILabel *)[cell viewWithTag:22];
    summary.text = [eventTime objectForKey:@"summary"];
    
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
