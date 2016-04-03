//
//  DayEventCell.m
//  LCSC
//
//  Created by Computer Science on 4/2/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "DayEventCell.h"


#define EXPANDED_HEIGHT (200)
#define DEFAULT_HEIGHT (44)

@implementation DayEventCell

-(void)checkHeight
{
    _descriptionLabel.hidden = (self.frame.size.height < EXPANDED_HEIGHT);
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
