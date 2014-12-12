//
//  LCSCWebViewController.m
//  campuslife
//
//  Created by Super Student on 10/28/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "AthleticsWebViewController.h"
#import "Reachability.h"

@interface AthWebViewController ()
{
    BOOL tornDown;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@end

@implementation AthWebViewController


-(void)viewWillAppear:(BOOL)animated{
    if (tornDown){
        [self loadContent];
    }
}


-(void)viewDidLoad{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self loadContent];
}

-(void)loadContent{
    tornDown = false;
    [self setUrl:[NSURL URLWithString:@"http://www.lcwarriors.com"]];
    
    
    [super viewDidLoad];
    _activity.hidden = NO;
    [self.activity startAnimating];
    Reachability *netReach = [Reachability reachabilityWithHostName:[_url host]];
    NetworkStatus netStatus = [netReach currentReachabilityStatus];
    
    
    
    if (netStatus == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Website Unavailable" message:@"This website is not currently available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self TearDownUIWebView];
        
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        [self.webView loadRequest:request];
        _webView.delegate = self;
    }
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activity stopAnimating];
    _activity.hidden = YES;
    if ([webView canGoBack]){
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    if ([webView canGoForward]){
         self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
         self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}
-(void) setUrl:(NSURL *)url {
    _url = url;
}
-(void) TearDownUIWebView{
    [_webView loadHTMLString:@"" baseURL:nil];
    [_webView stopLoading];
    [_webView setDelegate:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    [self.activity stopAnimating];
    _activity.hidden = YES;
    tornDown = true;
}

- (void) viewWillDisappear:(BOOL)animated {
    //[self TearDownUIWebView];
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

