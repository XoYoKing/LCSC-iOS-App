//
//  AllEventCell.m
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "AllEventCell.h"
#import "LCSCEvent.h"
#import "ExpandableEventCell.h"
#import <EventKit/EventKit.h>

@interface ExpandableEventCell (Private)
-(NSMutableAttributedString *)getDescriptionString;

@end

@implementation AllEventCell

-(void)hideDescription
{
    _eventDescriptionTextView.hidden = YES;
}


-(void)loadDescription
{
    NSMutableAttributedString *descStr = [self getDescriptionString];
    _eventDescriptionTextView.hidden = NO;
    [self.eventDescriptionTextView setAttributedText:descStr];
    _eventDescriptionTextView.backgroundColor = [UIColor clearColor];
}


-(IBAction)AddEventToCal:(UIButton *)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add To Calendar" message:@"Add Event To Device Calendar?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    [alert show];
    
}



@end
