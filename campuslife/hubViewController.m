//
//  hubViewController.m
//  campuslife
//
//  Created by Super Student on 5/4/14.
//  Copyright (c) 2014 LCSC. All rights reserved.
//

#import "hubViewController.h"
#import "Authentication.h"

@interface hubViewController ()

@property (nonatomic) Authentication *auth;
@property (nonatomic) BOOL signedIn;

@end

@implementation hubViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    _auth = [Authentication getSharedInstance];
    
    // Initialize the googleOAuth object.
    // Pay attention so as to initialize it with the initWithFrame: method, not just init.
    GoogleOAuth *googleOAuth = [[GoogleOAuth alloc] initWithFrame:self.view.frame];
    // Set self as the delegate.
    [googleOAuth setGOAuthDelegate:self];
    
    //Stores the authenticator so that it can be used
    [_auth setAuthenticator:googleOAuth];
    
    [self setSignedIn:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [_auth setDelegate:self];
}


-(IBAction)signInToGoogleCalendar:(id)sender
{
    if (_signedIn)
    {
        [[[Authentication getSharedInstance] getAuthenticator] revokeAccessToken];
    }
    
    [[_auth getAuthenticator] authorizeUserWithClienID:@"836202105226-07ulfvopjkp1qpr2f08i8df1rv5ebphs.apps.googleusercontent.com"
                                       andClientSecret:@"M8h6QjrFfVgKQ9slzyU6hO4q"
                                         andParent:self
                                             andScopes:[NSArray arrayWithObject:@"https://www.googleapis.com/auth/calendar"]];
}


#pragma mark - GoogleOAuth class delegate method implementation

-(void)authorizationWasSuccessful {
    [self setSignedIn:YES];

    [self performSegueWithIdentifier:@"hubToCalendar" sender:self];
}

-(void)responseFromServiceWasReceived:(NSString *)responseJSONAsString andResponseJSONAsData:(NSData *)responseJSONAsData{
}

-(void)accessTokenWasRevoked{
    [self setSignedIn:NO];
    //NSLog(@"Revoked!");
}


-(void)errorOccuredWithShortDescription:(NSString *)errorShortDescription andErrorDetails:(NSString *)errorDetails{
    // Just log the error messages.
    NSLog(@"%@", errorShortDescription);
    NSLog(@"%@", errorDetails);
}


-(void)errorInResponseWithBody:(NSString *)errorMessage{
    // Just log the error message.
    NSLog(@"%@", errorMessage);
}

@end
