//
//  RepeatUntilViewController.m
//  campuslife
//
//  Created by Super Student on 2/18/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "RepeatUntilViewController.h"
#import "AddEventParentViewController.h"

@interface RepeatUntilViewController ()

@end

@implementation RepeatUntilViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    AddEventParentViewController *eventController = (AddEventParentViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2];
    
    //NSDate* derrr = [eventController getRepUntil];
    
    if ([eventController getRepUntil] != NULL) {
        _untilDate.date = [eventController getRepUntil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    AddEventParentViewController *eventController = (AddEventParentViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
    
    [eventController setRepUntil:_untilDate.date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end