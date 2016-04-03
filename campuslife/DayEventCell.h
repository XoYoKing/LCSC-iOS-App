//
//  DayEventCell.h
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSCEvent.h"

@interface DayEventCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventDotImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UIButton *addButton;
@property (strong, nonatomic) IBOutlet UITextView *eventDescriptionTextView;
@property (strong, nonatomic) LCSCEvent *event;

-(void)loadDescription;
-(void)hideDescription;
+(NSInteger)ExpandedHeight;
+(NSInteger)DefaultHeight;
@end
