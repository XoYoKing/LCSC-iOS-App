//
//  EventDetailViewController.m
//  campuslife
//
//  Created by Super Student on 10/8/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "EventDetailViewController.h"
#import "CalendarViewController.h"
#import "WebViewViewController.h"
#import "LCSCEvent.h"
#import <EventKit/EventKit.h>

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad


@interface EventDetailViewController ()

@end

@implementation EventDetailViewController

-(void)viewWillAppear:(BOOL)animated
{
 
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (IPAD == IDIOM)
    {
        UIImageView *CurrentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadDetails.jpg"]];
        CurrentImage.frame = self.view.bounds;
        [[self view] addSubview:CurrentImage];
        [CurrentImage.superview sendSubviewToBack:CurrentImage];
    }
    else
    {
        UIImageView *CurrentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphoneDetails.jpg"]];
        CurrentImage.frame = self.view.bounds;
        [[self view] addSubview:CurrentImage];
        [CurrentImage.superview sendSubviewToBack:CurrentImage];
    }

    
    NSArray *dateHold;
    // Date info in different places depending on whether or not event is all day
    
    dateHold = [[[_selectedEvent getStartTimestamp] componentsSeparatedByString:@"T"][0]
                componentsSeparatedByString:@"-"];
    

    
    NSString *yearHold = [NSString stringWithFormat:@"%ld", (long)[_selectedEvent getStartYear]];
    NSString *dayHold = [NSString stringWithFormat:@"%ld", (long)[_selectedEvent getStartDay]];
    NSString *monthHold = [NSString stringWithFormat:@"%ld", (long)[_selectedEvent getStartMonth]];
    
    monthHold = [self convertMonthNumberToString:monthHold];
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@, %@", monthHold, dayHold,yearHold];
}

-(NSString *)convertMonthNumberToString:(NSString *)monthh
{
    NSString *month = [[NSString alloc] init];
    switch ([monthh intValue]) {
        case 1:
            month = @"January";
            break;
        case 2:
            month = @"February";
            break;
        case 3:
            month = @"March";
            break;
        case 4:
            month = @"April";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"August";
            break;
        case 9:
            month = @"September";
            break;
        case 10:
            month = @"October";
            break;
        case 11:
            month = @"November";
            break;
        case 12:
            month = @"December";
            break;
    }

    return month;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *timee = [[NSString alloc]init];
    //self.navigationItem.title = [NSString stringWithFormat:@"%@ %d, %d", [events getMonthBarDate], [events getSelectedDay], [events getSelectedYear]];
    
    if ([_selectedEvent isAllDay])
    {
        timee = @"All Day Event";
    }
    else
    {
        NSString *startTimeHold = [[[[_selectedEvent getStartTimestamp] componentsSeparatedByString:@"T"][1] componentsSeparatedByString:@"."][0] substringWithRange:NSMakeRange(0, 5)];
        NSString *endTimeHold = [[[[_selectedEvent getEndTimestamp] componentsSeparatedByString:@"T"][1] componentsSeparatedByString:@"."][0] substringWithRange:NSMakeRange(0, 5)];
        startTimeHold = [self twentyFourToTwelve:startTimeHold];
        endTimeHold = [self twentyFourToTwelve:endTimeHold];
        timee = [NSString stringWithFormat:@"%@ - %@",startTimeHold,endTimeHold];
    }
    
    
    NSString *titleToParse = [_selectedEvent getSummary];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@":" withString:@"\n"];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@": " withString:@"\n"];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    
    NSDictionary *titleDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size:18.0] forKey:NSFontAttributeName];
    NSDictionary *locationDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica" size:15.0] forKey:NSFontAttributeName];
    NSDictionary *timeDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica" size:13.0] forKey:NSFontAttributeName];
    NSDictionary *descDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica" size:14.0] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", titleToParse] attributes:titleDict];
    
    NSMutableAttributedString *attributedTime = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", timee] attributes:timeDict];
    
    NSMutableAttributedString *attributedLocation = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [_selectedEvent getLocation]] attributes:locationDict];
    
    NSMutableAttributedString *attributedDesc = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [_selectedEvent getDescription]] attributes:descDict];
    
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedTitle.length)];
    [attributedLocation addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedLocation.length)];
    [attributedTime addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedTime.length)];
    
    
    
    
    
    NSMutableAttributedString *Final = [[NSMutableAttributedString alloc]init];
    [Final appendAttributedString:attributedTitle];
    [Final appendAttributedString:attributedLocation];
    [Final appendAttributedString:attributedTime];
    [Final appendAttributedString:attributedDesc];
    
    [self.Description setAttributedText:Final];
    _Description.backgroundColor = [UIColor clearColor];
}


-(IBAction)AddEventToCal:(UIBarButtonItem *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add To Calendar" message:@"Add Event To Device Calendar?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert show];

}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex{
    
    if (buttonIndex == 1) {
        EKEventStore *store = [[EKEventStore alloc] init];
        

        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (!granted) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Calendar Access Not Granted"
                                                                message:@"Go to\nSettings > Privacy > Calendars\nand enable access to LCSC to add events to your personal calendar."
                                                               delegate:nil cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                return;
            }
            else{
                EKEvent *event = [EKEvent eventWithEventStore:store];
                [event setTitle:[_selectedEvent getSummary]];//solved
                [event setLocation:[_selectedEvent getLocation]];//solved
                [event setNotes:[_selectedEvent getDescription]];//solved

                
                if ([_selectedEvent isAllDay])
                {
                    [event setAllDay:true];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                    NSString *startDateString = [_selectedEvent getStartTimestamp];
                    //NSString *endDateString = [[_eventDict objectForKey:@"end"] objectForKey:@"date"];
                    
                    NSDate *start = [[NSDate alloc] init];
                    //NSDate *end = [[NSDate alloc] init];
                    
                    start = [dateFormatter dateFromString:startDateString];
                    //end = [dateFormatter dateFromString:endDateString];
                    
                    [event setStartDate:start];
                    /*
                     This is not the best way do to it, but trying to get an end date was weird.
                    so I just set both to the same day. I guess you can't save multi day events.
                    sorry but I'm lazy and junk and it was a hot mess. In the end we don't really
                    want to work with the recurrance stuff that is provided in the jsons anyway so 
                    there is no good way to do multi day all day events.
                    I'll leave the code commented out for the end date stuff incase someone has
                    a weird breakthrough on how to do it in the future!
                    */
                    [event setEndDate:start];
                }
                else{
                    //not all day event

                    [event setAllDay:false];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                    
/* This code causes errors for some reason? - Kyle

            //clayton
          //          NSString *startDateString = [[_eventDict objectForKey:@"start"] objectForKey:@"dateTime"];
            //        NSString *endDateString = [[_eventDict objectForKey:@"end"] objectForKey:@"dateTime"];
                    
                    NSMutableString *mutableStartDate = [startDateString mutableCopy];
                    NSMutableString *mutableEndDate = [endDateString mutableCopy];
                    
                    
                    //Dont ask. adding the .000 made it a lot easier (I followed a stackOverflow article)
                    //Me and date formatters do not get along :(
                    [mutableStartDate insertString:@".000" atIndex:19];
                    [mutableEndDate insertString:@".000" atIndex:19];
                    
            
                    [mutableStartDate deleteCharactersInRange:NSMakeRange(mutableStartDate.length - 3, 1)];
                    [mutableEndDate deleteCharactersInRange:NSMakeRange(mutableEndDate.length - 3, 1)];


                    NSDate *start = [dateFormatter dateFromString:mutableStartDate];
                    NSDate *end = [dateFormatter dateFromString:mutableEndDate];
                    [event setStartDate:start];
                    [event setEndDate:end];
 */
                }

                [event setCalendar:[store defaultCalendarForNewEvents]];
                NSError *err = nil;
                [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
                
                
                
            }
        }];
    }
    
}


- (void)viewDidAppear:(BOOL)animated {
    //[self.navigationController popToViewController:self animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showURL"]) {
        
        WebViewViewController *wv = [segue destinationViewController];
        [wv setUrl:_urlSelected];
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    _urlSelected = URL;
    [self performSegueWithIdentifier:@"showURL" sender:self];
    
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
