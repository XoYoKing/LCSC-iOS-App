//
//  AllEventViewController.h
//  campuslife
//
//  Created by Super Student on 10/12/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
