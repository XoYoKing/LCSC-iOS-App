//
//  LCSCWebViewController.h
//  campuslife
//
//  Created by Super Student on 10/28/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AthWebViewController : UIViewController <UIWebViewDelegate>

@property (copy, nonatomic) NSURL *url;

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

-(void) TearDownUIWebView;
-(void) setUrl:(NSURL *)url;

@end