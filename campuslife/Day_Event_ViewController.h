//
//  Day_Event_ViewController.h
//  LCSC Campus Life
//
//  Created by Super Student on 11/7/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Day_Event_ViewController : UITableViewController

/*
 *  Contains the index for month array.
 */
@property (nonatomic, setter=setDay:) NSInteger day;
@property (nonatomic, setter=setEvents:) NSArray *dayEvents;
@end
