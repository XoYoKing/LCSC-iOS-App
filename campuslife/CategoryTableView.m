//
//  CategoryTableView.m
//  dropdown2
//
//  Created by Student on 3/31/16.
//  Copyright © 2016 lcsc.edu. All rights reserved.
//

#import "CategoryTableView.h"
#import "Preferences.h"

@interface CategoryTableView ()
    @property (nonatomic, strong) NSArray *categories;
    @property (nonatomic, strong) NSArray *categoryColors;
@end

@implementation CategoryTableView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _categories = @[@"Academics", @"Entertainment", @"Student Activities",
                    @"Campus Rec", @"Residence Life", @"Warrior Athletics"];
    
    _categoryColors = @[[[UIColor alloc] initWithRed:96 / 255.0 green:96 / 255.0 blue:96 / 255.0 alpha:0.5], // light gray
                        [[UIColor alloc] initWithRed:144 / 255.0 green:0 / 255.0 blue:0 / 255.0 alpha:0.5], // red
                        [[UIColor alloc] initWithRed:240 / 255.0 green:144 / 255.0 blue:48 / 255.0 alpha:0.5], // orange
                        [[UIColor alloc] initWithRed:0 / 255.0 green:144 / 255.0 blue:48 / 255.0 alpha:0.5], // green
                        [[UIColor alloc] initWithRed:0 / 255.0 green:192 / 255.0 blue:192 / 255.0 alpha:0.5], // teal
                        [[UIColor alloc] initWithRed:0 / 255.0 green:96 / 255.0 blue:144 / 255.0 alpha:0.5]]; // blue
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    Preferences *prefs = [Preferences getSharedInstance];
    for(int i = 0; i < _categories.count; ++i) {
        NSString *cat = [_categories objectAtIndex:i];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:i inSection:0]];
        if([prefs getPreference:cat]) {
            [self showCellAsSelected:cell atIndex:i];
        } else {
            [self showCellAsDeselected:cell atIndex:i];
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showCellAsSelected:(UITableViewCell *)cell atIndex:(NSInteger) ind
{
    UILabel *cellLabel = [cell viewWithTag:10];
    cellLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [_categoryColors objectAtIndex:ind];
}


-(void)showCellAsDeselected:(UITableViewCell *)cell atIndex:(NSInteger) ind
{
    UILabel *cellLabel = [cell viewWithTag:10];
    cellLabel.textColor = [_categoryColors objectAtIndex:ind];
    cell.backgroundColor = [UIColor whiteColor];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:@NO];
    NSString *catSelected = [_categories objectAtIndex:indexPath.row];
    Preferences *prefs = [Preferences getSharedInstance];
    BOOL active = [prefs getPreference:catSelected];
    
    // flip the active switch
    if(!active) {
        [self showCellAsSelected:cell atIndex:indexPath.row];
    }
    else {
        [self showCellAsDeselected:cell atIndex:indexPath.row];
    }
    [prefs negatePreference:catSelected];
}


@end
