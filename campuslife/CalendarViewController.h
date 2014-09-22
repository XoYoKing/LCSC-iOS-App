//
//  ViewController.h
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoogleOAuth.h"

@interface CalendarViewController : UIViewController <GoogleOAuthDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftArrow;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightArrow;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addEventButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *btnEntertainment;
@property (weak, nonatomic) IBOutlet UIButton *btnAcademics;
@property (weak, nonatomic) IBOutlet UIButton *btnStudentActivities;
@property (weak, nonatomic) IBOutlet UIButton *btnResidenceLife;
@property (weak, nonatomic) IBOutlet UIButton *btnWarriorAthletics;
@property (weak, nonatomic) IBOutlet UIButton *btnCampusRec;


@property (nonatomic, setter=setShouldRefresh:) BOOL shouldRefresh;


- (void)onTick:(NSTimer*)timer;
- (void)onTickForDelay:(NSTimer*)timer;

- (IBAction)radioSelected:(UIButton *)sender;

- (IBAction)backMonthOffset:(id)sender;
- (IBAction)forwardMonthOffset:(id)sender;

- (int)getIndexOfSubstringInString:(NSString *)substring :(NSString *)string;
- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day;
- (NSString*)toStringFromDateTime:(NSDate*)datetime;
- (void) getEventsForMonth:(NSInteger) month :(NSInteger) year;

- (void) authenticate;

@end
