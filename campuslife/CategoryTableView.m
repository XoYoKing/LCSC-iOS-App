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
    
    _categoryColors = @[[UIColor lightGrayColor], // light gray
                        [UIColor redColor], // red
                        [UIColor orangeColor], // orange
                        [UIColor greenColor], // green
                        [[UIColor alloc] initWithRed: 0 green: 1 blue: 1 alpha:1.0], // teal
                        [UIColor blueColor]]; // blue
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
