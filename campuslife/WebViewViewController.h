//
//  WebViewViewController.h
//  campuslife
//
//  Created by Super Student on 10/28/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController

@property (copy, nonatomic) NSURL *url;

@property (nonatomic, weak) IBOutlet UIWebView *webView;

-(void) setUrl:(NSURL *)url;

@end