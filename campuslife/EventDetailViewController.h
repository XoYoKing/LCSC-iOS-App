//
//  EventDetailViewController.h
//  campuslife
//
//  Created by Super Student on 10/8/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCSCEvent.h"

@interface EventDetailViewController : UIViewController<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *Time;
@property (weak, nonatomic) IBOutlet UILabel *Title;
@property (weak, nonatomic) IBOutlet UILabel *Location;
@property (weak, nonatomic) IBOutlet UITextView *Description;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;
@property (weak, nonatomic) NSURL *urlSelected;
@property (nonatomic,setter = setEvent:) LCSCEvent *selectedEvent;
@end
