//
//  ExpandableEventCell.m
//  LCSC
//
//  Created by Computer Science on 4/9/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "ExpandableEventCell.h"
#import "LCSCEvent.h"
#import "MonthFactory.h"
#import <EventKit/EventKit.h>



@implementation ExpandableEventCell


-(NSMutableAttributedString *)getDescriptionString
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
    
    return Final;
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
                //EKEvent *calEvent = [EKEvent eventWithEventStore:store];
                //[calEvent setTitle:[_event getSummary]];//solved
                //[calEvent setLocation:[_event getLocation]];//solved
                //[calEvent setNotes:[_event getDescription]];//solved
                
                NSArray *reocurrences = [MonthFactory getReocurrencesOfEvent:_event];
                NSInteger reCount;
                reCount = [reocurrences count];
                NSLog(@"%ld",(long)reCount);
                if ([reocurrences count] > 1)
                {
                    UIAlertController * alert  = [UIAlertController alertControllerWithTitle:@"Multiple occurences detected."
                                                                                     message:@"Would you like to add all similar occurences of this event?"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* no = [UIAlertAction actionWithTitle:@"NO"
                                                                 style:UIAlertActionStyleCancel
                                                               handler:nil];
                    UIAlertAction* yes = [UIAlertAction actionWithTitle:@"YES"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    [alert dismissViewControllerAnimated:YES completion:nil];
                                                                }];
                    [alert addAction:no];
                    [alert addAction:yes];
                    //[self presentViewController:alert animated:YES completion:nil];
                    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
                    //[self presentViewController:alert animated:YES completion:nil];
                    /*
                    UIAlertView *multiEvents = [[UIAlertView alloc] initWithTitle:@"Multiple occurences detected."
                                                                          message:@"Would you like to add future occurences of this event?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    [multiEvents show];*/
                    NSInteger i = 0;
                    if (buttonIndex == 1)
                    {
                        for(i; i < [reocurrences count]; i++)
                        {
                            //add events to calendar
                            LCSCEvent *reocurrencesEvent = reocurrences[i];
                            EKEvent *calEvent = [EKEvent eventWithEventStore:store];
                            [calEvent setTitle:[reocurrencesEvent getSummary]];//solved
                            [calEvent setLocation:[reocurrencesEvent getLocation]];//solved
                            [calEvent setNotes:[reocurrencesEvent getDescription]];//solved
                            if ([reocurrencesEvent isAllDay])
                            {
                                [calEvent setAllDay:true];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                NSString *startDateString = [reocurrencesEvent getStartTimestamp];
                                NSDate *start = [[NSDate alloc] init];
                                start = [dateFormatter dateFromString:startDateString];
                                [calEvent setStartDate:start];
                                [calEvent setEndDate:start];
                            }
                            else
                            {
                                [calEvent setAllDay:false];
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                                
                                
                                //clayton
                                NSString *startDateString = [reocurrencesEvent getStartTimestamp];
                                NSString *endDateString = [reocurrencesEvent getEndTimestamp];
                                
                                NSMutableString *mutableStartDate = [startDateString mutableCopy];
                                NSMutableString *mutableEndDate = [endDateString mutableCopy];
                                
                                
                                [mutableStartDate insertString:@".000" atIndex:19];
                                [mutableEndDate insertString:@".000" atIndex:19];
                                
                                
                                [mutableStartDate deleteCharactersInRange:NSMakeRange(mutableStartDate.length - 3, 1)];
                                [mutableEndDate deleteCharactersInRange:NSMakeRange(mutableEndDate.length - 3, 1)];
                                
                                
                                NSDate *start = [dateFormatter dateFromString:mutableStartDate];
                                NSDate *end = [dateFormatter dateFromString:mutableEndDate];
                                [calEvent setStartDate:start];
                                [calEvent setEndDate:end];
                            }
                            
                            [calEvent setCalendar:[store defaultCalendarForNewEvents]];
                            NSError *err = nil;
                            [store saveEvent:calEvent span:EKSpanThisEvent commit:YES error:&err];
                            //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
                        }
                    }
                    else{
                        
                        EKEvent *calEvent = [EKEvent eventWithEventStore:store];
                        [calEvent setTitle:[_event getSummary]];//solved
                        [calEvent setLocation:[_event getLocation]];//solved
                        [calEvent setNotes:[_event getDescription]];//solved
                        
                        if ([_event isAllDay])
                        {
                            [calEvent setAllDay:true];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            
                            NSString *startDateString = [_event getStartTimestamp];
                            //NSString *endDateString = [[_eventDict objectForKey:@"end"] objectForKey:@"date"];
                            
                            NSDate *start = [[NSDate alloc] init];
                            //NSDate *end = [[NSDate alloc] init];
                            
                            start = [dateFormatter dateFromString:startDateString];
                            //end = [dateFormatter dateFromString:endDateString];
                            
                            [calEvent setStartDate:start];
                            /*
                             This is not the best way do to it, but trying to get an end date was weird.
                             so I just set both to the same day. I guess you can't save multi day events.
                             sorry but I'm lazy and junk and it was a hot mess. In the end we don't really
                             want to work with the recurrance stuff that is provided in the jsons anyway so
                             there is no good way to do multi day all day events.
                             I'll leave the code commented out for the end date stuff incase someone has
                             a weird breakthrough on how to do it in the future!
                             */
                            
                            [calEvent setEndDate:start];
                        }
                        else{
                            //not all day event
                            
                            [calEvent setAllDay:false];
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                            
                            
                            //clayton
                            NSString *startDateString = [_event getStartTimestamp];
                            NSString *endDateString = [_event getEndTimestamp];
                            
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
                            [calEvent setStartDate:start];
                            [calEvent setEndDate:end];
                        }
                        [calEvent setCalendar:[store defaultCalendarForNewEvents]];
                        NSError *err = nil;
                        [store saveEvent:calEvent span:EKSpanThisEvent commit:YES error:&err];
                        //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
                    }
                }
                
                else{
                    
                    EKEvent *calEvent = [EKEvent eventWithEventStore:store];
                    [calEvent setTitle:[_event getSummary]];//solved
                    [calEvent setLocation:[_event getLocation]];//solved
                    [calEvent setNotes:[_event getDescription]];//solved
                    
                    if ([_event isAllDay])
                    {
                        [calEvent setAllDay:true];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    
                        NSString *startDateString = [_event getStartTimestamp];
                        //NSString *endDateString = [[_eventDict objectForKey:@"end"] objectForKey:@"date"];
                    
                        NSDate *start = [[NSDate alloc] init];
                        //NSDate *end = [[NSDate alloc] init];
                    
                        start = [dateFormatter dateFromString:startDateString];
                        //end = [dateFormatter dateFromString:endDateString];
                    
                        [calEvent setStartDate:start];
                        /*
                         This is not the best way do to it, but trying to get an end date was weird.
                         so I just set both to the same day. I guess you can't save multi day events.
                         sorry but I'm lazy and junk and it was a hot mess. In the end we don't really
                         want to work with the recurrance stuff that is provided in the jsons anyway so
                         there is no good way to do multi day all day events.
                         I'll leave the code commented out for the end date stuff incase someone has
                         a weird breakthrough on how to do it in the future!
                         */
                    
                        [calEvent setEndDate:start];
                    }
                    else{
                        //not all day event
                    
                        [calEvent setAllDay:false];
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ"];
                    
                     
                        //clayton
                        NSString *startDateString = [_event getStartTimestamp];
                        NSString *endDateString = [_event getEndTimestamp];
                     
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
                        [calEvent setStartDate:start];
                        [calEvent setEndDate:end];
                    }
                    [calEvent setCalendar:[store defaultCalendarForNewEvents]];
                    NSError *err = nil;
                    [store saveEvent:calEvent span:EKSpanThisEvent commit:YES error:&err];
                    //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
                }
                
                //[calEvent setCalendar:[store defaultCalendarForNewEvents]];
                //NSError *err = nil;
                //[store saveEvent:calEvent span:EKSpanThisEvent commit:YES error:&err];
                //NSString *savedEventId = event.eventIdentifier;  //this is so you can access this event later
            }
        }];
    }
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
