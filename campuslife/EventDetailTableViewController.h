//
//  EventDetailTableViewController.h
//  campuslife
//
//  Created by Super Student on 3/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 An interface for the EventDetailTableViewController class
 */
@interface EventDetailTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

/**
 Contains the selected day
 */
@property (nonatomic, setter = setDay:) NSInteger day;

/**
 Stores the dictionary of events for the selected day
 */
@property (copy, nonatomic,setter = setEvent:) NSDictionary *eventDict;


@end
