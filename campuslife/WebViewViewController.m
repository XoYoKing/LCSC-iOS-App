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
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (strong, nonatomic) ScriptWebView *script;
@end

@implementation WebViewViewController

//@synthesize webView = _webView;
- (void)viewDidLoad {
    
    
    
    
    [super viewDidLoad];
    [_menuButton addTarget:self action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:[[self revealViewController] panGestureRecognizer]];
    [self.view addGestureRecognizer:[[self revealViewController] tapGestureRecognizer]];
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor blackColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.webView.frame), 1.0f);
    [self.webView.layer addSublayer:upperBorder];
    
    
    _script = [[ScriptWebView alloc]init];
    [self.activity startAnimating];
    Reachability *netReach = [Reachability reachabilityWithHostName:[_url host]];
    NetworkStatus netStatus = [netReach currentReachabilityStatus];
    //self.performSegueWithIdentifier("backToMenu", sender: self)
    


    if (netStatus == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Website Unavailable" message:@"This website is not currently available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self TearDownUIWebView];

    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_url];
        [self.webView loadRequest:request];
        NSString *requestPath = [[request URL] absoluteString];
        _currentURL = requestPath;
        _webView.delegate = self;
    }

}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.activity stopAnimating];
    _activity.hidden = YES;
    
    //runs a javascript based on the page the webView is
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
//    imageView.layer.cornerRadius = 5
//    imageView.clipsToBounds = true
//    imageView.layer.borderColor = UIColor.blackColor().CGColor
//    imageView.layer.borderWidth = 2.0
    [super didReceiveMemoryWarning];
    [self TearDownUIWebView];
}

@end
