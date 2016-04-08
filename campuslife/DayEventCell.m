//
//  DayEventCell.m
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "DayEventCell.h"
#import "LCSCEvent.h"
#import <EventKit/EventKit.h>

#define EXPANDED_HEIGHT (300)
#define DEFAULT_HEIGHT (44)

@implementation DayEventCell


-(void)hideDescription
{
    _eventDescriptionTextView.hidden = YES;
}


-(void)loadDescription
{
    NSString *titleToParse = [_event getSummary];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@":" withString:@"\n"];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@": " withString:@"\n"];
    titleToParse = [titleToParse stringByReplacingOccurrencesOfString:@"(" withString:@"\n("];
    
    NSDictionary *titleDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica-Bold" size:18.0] forKey:NSFontAttributeName];
    NSDictionary *locationDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica" size:15.0] forKey:NSFontAttributeName];
    NSDictionary *descDict = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"Helvetica" size:14.0] forKey:NSFontAttributeName];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", titleToParse] attributes:titleDict];
    
    
    NSMutableAttributedString *attributedLocation = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [_event getLocation]] attributes:locationDict];
    
    NSMutableAttributedString *attributedDesc = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n", [_event getDescription]] attributes:descDict];
    
    [attributedTitle addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedTitle.length)];
    [attributedLocation addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedLocation.length)];
    
    NSMutableAttributedString *Final = [[NSMutableAttributedString alloc]init];
    [Final appendAttributedString:attributedLocation];
    [Final appendAttributedString:attributedDesc];
    
    _eventDescriptionTextView.hidden = NO;
    [self.eventDescriptionTextView setAttributedText:Final];
    _eventDescriptionTextView.backgroundColor = [UIColor clearColor];
}


-(IBAction)AddEventToCal:(UIButton *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add To Calendar" message:@"Add Event To Device Calendar?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert show];
    
}


- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger) buttonIndex{
    /*
    if (buttonIndex == 1) {
        EKEventStore *store = [[EKEventStore alloc] init];
        
        
        [store requestAccessToEntityType:EKEntityTypeEvent completion:^(bool granted, NSError *error) {
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
                [event setTitle:[_event getSummary]];//solved
                [event setLocation:[_event getLocation]];//solved
                [event setNotes:[_event getDescription]];//solved
                
                
                if ([_event isAllDay])
                {
                    [event setAllDay:true];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                    NSString *startDateString = [_event getStartTimestamp];
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
                     
                }
                
                [event setCalendar:[store defaultCalendarForNewEvents]];
                NSError *err = nil;
                [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
            }
        }];
    }
    */
}

+(NSInteger)ExpandedHeight
{
    return EXPANDED_HEIGHT;
}

+(NSInteger)DefaultHeight
{
    return DEFAULT_HEIGHT;
}

@end
