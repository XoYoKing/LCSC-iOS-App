//
//  ContactInfo.m
//  LCSC
//
//  Created by Super Student on 11/20/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "ContactInfo.h"
#import "SWRevealViewController.h"
#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad
@interface ContactInfo ()
{
    NSString *numberToCall;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@end

@implementation ContactInfo
-(void)viewWillAppear:(BOOL)animated{
    numberToCall = @"";
}
- (void)viewDidLoad {

    self.view.backgroundColor = [UIColor whiteColor];
    _menuButton.target = [self revealViewController];
    _menuButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    
    if (IPAD == IDIOM)
    {
        self.tableView.rowHeight = 66;
        UIImageView *CurrentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ipadE.jpg"]];
        CurrentImage.frame = self.view.bounds;
        [[self view] addSubview:CurrentImage];
        [CurrentImage.superview sendSubviewToBack:CurrentImage];
    }
    else
    {
        self.tableView.rowHeight = 44;
        UIImageView *CurrentImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphoneE.jpg"]];
        CurrentImage.frame = self.view.bounds;
        [[self view] addSubview:CurrentImage];
        [CurrentImage.superview sendSubviewToBack:CurrentImage];
    }

    //_contactTableiPad.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //_contactTableiPhone.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.tableView.separatorColor = [UIColor clearColor];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellCount" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *numberLabel = (UILabel *)[cell viewWithTag:2];
    if(indexPath.row == 0){
        titleLabel.text = @"Emergency Services";
        numberLabel.text = @"911";
    }else if (indexPath.row == 1){
        titleLabel.text = @"Campus Security Mobile";
        numberLabel.text = @"208-792-2815";
    }else if (indexPath.row == 2){
        titleLabel.text = @"Campus Security Office";
        numberLabel.text = @"208-792-5272";
    }else if (indexPath.row == 3){
        titleLabel.text = @"Student Counseling";
        numberLabel.text = @"208-792-2291";
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UILabel *nmbrLbl = (UILabel *)[cell viewWithTag:2];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    NSString *numberAsString = [@"tel://" stringByAppendingString:nmbrLbl.text];
    numberToCall = numberAsString;
    if (IPAD != IDIOM)
    {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Call %@",name.text]
                                                    message:[NSString stringWithFormat:@"%@",nmbrLbl.text]
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Call", nil];
    [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != [alertView cancelButtonIndex]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:numberToCall]];
    }else{
        numberToCall = @"";
    }
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
