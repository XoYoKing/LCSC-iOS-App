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

-(void) TearDownUIWebView{
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView removeFromSuperview];
    [_webView stopLoading];
    [_webView setDelegate:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
}

- (void) viewWillDisappear:(BOOL)animated {
    [self TearDownUIWebView];
}

-(void) viewDidDisappear:(BOOL)animated
{
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [self TearDownUIWebView];
}

@end
