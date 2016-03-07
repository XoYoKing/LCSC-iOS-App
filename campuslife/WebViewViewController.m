//
//  WebViewViewController.m
//  campuslife
//
//  Created by Super Student on 10/28/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "WebViewViewController.h"
#import "Reachability.h"
#import "LCSC-Swift.h"

@interface WebViewViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *back;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) NSString *currentURL;
@property (strong, nonatomic) ScriptWebView *script;
@end

@implementation WebViewViewController

//@synthesize webView = _webView;
- (void)viewDidLoad {
    [super viewDidLoad];
    _script = [[ScriptWebView alloc]init];
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
        NSString *requestPath = [[request URL] absoluteString];
//       printf("%s\n",[requestPath UTF8String]);
        _currentURL = requestPath;
        _webView.delegate = self;
    }

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activity stopAnimating];
    _activity.hidden = YES;
    [_webView stringByEvaluatingJavaScriptFromString:[_script getScript:_currentURL]];
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
    [self.activity stopAnimating];
    _activity.hidden = YES;
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
