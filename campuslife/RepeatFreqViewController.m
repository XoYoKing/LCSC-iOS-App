//
//  RepeatFreqViewController.m
//  campuslife
//
//  Created by Super Student on 2/18/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "RepeatFreqViewController.h"
#import "AddEventParentViewController.h"

@interface RepeatFreqViewController ()

@property(strong, nonatomic) NSString *repFreq;

@end

@implementation RepeatFreqViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _repFreq = NULL;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_repFreq != NULL) {
        AddEventParentViewController *eventController = (AddEventParentViewController *)[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-1];
        
        [eventController setRepFreq:_repFreq];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (indexPath.row == 0)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Never";
    }
    else if (indexPath.row == 1)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Weekly";
    }
    else if (indexPath.row == 2)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Bi-Weekly";
    }
    else if (indexPath.row == 3)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Monthly";
    }
    else if (indexPath.row == 4)
    {
        ((UILabel *)[cell viewWithTag:5]).text = @"Yearly";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        _repFreq = @"Never";
    }
    else if (indexPath.row == 1)
    {
        _repFreq = @"Weekly";
    }
    else if (indexPath.row == 2)
    {
        _repFreq = @"Bi-Weekly";
    }
    else if (indexPath.row == 3)
    {
        _repFreq = @"Monthly";
    }
    else if (indexPath.row == 4)
    {
        _repFreq = @"Yearly";
    }
    
    [self.navigationController popViewControllerAnimated:NO];
}

@end