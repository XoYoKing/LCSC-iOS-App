//
//  WebViewViewController.m
//  campuslife
//
//  Created by Super Student on 10/28/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

//@synthesize webView = _webView;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [self.webView loadRequest:request];
}

-(void) setUrl:(NSURL *)url {
    _url = url;
}

- (void) viewWillDisappear:(BOOL)animated {
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView removeFromSuperview];
    [_webView setDelegate:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_webView reload];
}

@end
