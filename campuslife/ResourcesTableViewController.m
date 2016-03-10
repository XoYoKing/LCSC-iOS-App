//
//  ResourcesTableViewController.m
//  LCSC
//
//  Created by Computer Science on 2/8/16.
//  Copyright © 2016 LCSC. All rights reserved.
//

#import "ResourcesTableViewController.h"
#import "WebViewViewController.h"
#import "SWRevealViewController.h"

@interface ResourcesTableViewController ()
{
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@end

@implementation ResourcesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Profile"]) {
        
    }
    else {
        WebViewViewController *dest = (WebViewViewController *)[segue destinationViewController];
        NSString *url, *title;
        if([segue.identifier  isEqualToString: @"LCSC"]) {
            url = @"http://www.lcsc.edu";
            title = @"LCSC";
            
        } else if([segue.identifier isEqualToString:@"Athletics"]) {
            url = @"http://www.lcwarriors.com";
            title = @"Warrior Athletics";
            
        } else if([segue.identifier isEqualToString:@"WarriorWeb"]) {
            url = @"https://warriorwebss.lcsc.edu/Student/Account/Login?ReturnUrl=%2fStudent%2fPlanning%2fDegreePlans";
            title = @"Warrior Web";
            
        } else if ([segue.identifier isEqualToString:@"LCMail"]) {
            url = @"http://www.lcsc.edu/lcmail/";
            title = @"LC Mail";
        }
        [dest setUrl:[NSURL URLWithString:url]];
        [dest setTitle:title];
    }

}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/






- (IBAction)goBack:(id)sender {
    [self setTitle:@"Important Links 'n Shit"];
}


@end
