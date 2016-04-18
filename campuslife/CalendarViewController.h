//
//  ViewController.h
//  LCSC Campus Life
//
//  Created by Super Student on 10/29/13.
//  Copyright (c) 2013 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarViewController : UIViewController < UICollectionViewDelegate, UICollectionViewDataSource, UIPopoverPresentationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftArrow;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightArrow;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeLeft;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeRight;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeUp;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeDown;



@property (weak, nonatomic) IBOutlet UIBarButtonItem *addEventButton;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, setter=setShouldRefresh:) BOOL shouldRefresh;



- (void)onTickForDelay:(NSTimer*)timer;

- (IBAction)backMonthOffset:(id)sender;
- (IBAction)forwardMonthOffset:(id)sender;

- (NSDate *)returnDateForMonth:(NSInteger)month year:(NSInteger)year day:(NSInteger)day;
- (void) setMonthNeedsLoaded:(BOOL)monthNeedsLoaded;

@end
