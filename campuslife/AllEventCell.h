//
//  AllEventCell.h
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSCEvent.h"
#import "ExpandableEventCell.h"

@interface AllEventCell : ExpandableEventCell
@property (strong, nonatomic) IBOutlet UIImageView *dotImageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UITextView *eventDescriptionTextView;

-(void)loadDescription;
-(void)hideDescription;
@end
