//
//  AddEventParentViewController.m
//  campuslife
//
//  Created by Super Student on 2/18/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "AddEventParentViewController.h"

@interface AddEventParentViewController ()

@end

@implementation AddEventParentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    _repeatFreq = @"Never";
    _repeatUntil = NULL;
    
    _descriptionView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _descriptionView.layer.borderWidth = 1.0f;
    _descriptionView.layer.cornerRadius = 10.0f;
    _descriptionView.clipsToBounds = YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
