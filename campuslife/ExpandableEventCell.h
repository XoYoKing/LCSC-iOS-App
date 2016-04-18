//
//  ExpandableEventCell.h
//  LCSC
//
//  Created by Computer Science on 4/9/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSCEvent.h"

#if IDIOM == IPAD
#define EXPANDED_HEIGHT (200)

#else
#define EXPANDED_HEIGHT (150)

#endif

#define DEFAULT_HEIGHT (44)

@interface ExpandableEventCell : UITableViewCell
@property (strong, nonatomic) LCSCEvent *event;

+(NSInteger)ExpandedHeight;
+(NSInteger)DefaultHeight;
@end
