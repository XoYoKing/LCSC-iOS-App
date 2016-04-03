//
//  DayEventCell.h
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayEventCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *summaryLabel;
@property (strong, nonatomic) IBOutlet UIImageView *eventDotImageView;
@property (strong, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;

+(NSInteger)ExpandedHeight;
+(NSInteger)DefaultHeight;
@end
