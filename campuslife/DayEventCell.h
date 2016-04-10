//
//  DayEventCell.h
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSCEvent.h"
#import "ExpandableEventCell.h"

@interface DayEventCell : ExpandableEventCell
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventDotImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UITextView *eventDescriptionTextView;

-(void)loadDescription;
-(void)hideDescription;
@end
