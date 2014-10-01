//
//  hubViewController.m
//  campuslife
//
//  Created by Super Student on 5/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "hubViewController.h"

@interface hubViewController ()

@end

@implementation hubViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(IBAction)segueToCalendar:(id)sender
{
    [self performSegueWithIdentifier:@"hubToCalendar" sender:self];
}

@end
