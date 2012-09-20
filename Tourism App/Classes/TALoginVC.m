//
//  TALoginVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALoginVC.h"
#import "TAAppDelegate.h"
#import "JSONKit.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "TAFeedVC.h"
#import "TAExploreVC.h"
#import "TACameraVC.h"
#import "TAProfileVC.h"
#import "TANotificationsVC.h"
#import "TAForgottenPasswordVC.h"
#import "TALoginLandingVC.h"

static NSString *kAccountUsernameSavedKey = @"accountUsernameSavedKey";
static NSString *kSavedUsernameKey = @"savedUsernameKey";
static NSString *kSavedPasswordKey = @"savedPasswordKey";
static NSString *kUserDefaultCityKey = @"userDefaultCityKey";
static NSString *kSkipLoginLandingKey = @"skipLoginLandingKey";

@interface TALoginVC ()

@end

@implementation TALoginVC

@synthesize passwordField, usernameField, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Set up nav bar
	[self initNavBar];

    // Pre-populate the login form with credentials
	// that have been used successfully previously
	[self retrievePreviousAccountDetails];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	[usernameField release];
	self.usernameField = nil;
	[passwordField release];
	self.passwordField = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[usernameField release];
	[passwordField release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[self.usernameField becomeFirstResponder];
	
	[super viewWillAppear:animated];
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is username - put the focus on the password field
	if (textField == self.usernameField)
		[self.passwordField becomeFirstResponder];
	
    else if (textField == self.passwordField) {
		
		// Hide the keyboard
        [textField resignFirstResponder];
		
		// show loading animation
		[self showLoading];
		
        // Login the user
        [self login];
	}
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}


#pragma MY-METHODS

- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)login {
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&password=%@", self.usernameField.text, self.passwordField.text];
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Login"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
    loginFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedLoginResponse:)];
    [loginFetcher start];
}


// Example fetcher response handling
- (void)receivedLoginResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
	NSAssert(aFetcher == loginFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL loginSuccess = NO;
	BOOL skipLoginLanding;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		NSLog(@"LOGIN RESULTS:%@", results);
		
		for (int i = 0; i < [[results allKeys] count]; i++) {
			
			NSString *key = [[results allKeys] objectAtIndex:i];
			NSString *value = [results objectForKey:key];
			
			if ([key isEqualToString:@"result"]) loginSuccess = (([value isEqualToString:@"ok"]) ? YES : NO);
			
			// Pass the token value to the AppDelegate to be stored as 
			// the session token for all API calls
			else if ([key isEqualToString:@"token"]) [[self appDelegate] setToken:[results objectForKey:key]];
			
			if (loginSuccess) {
			
				NSDictionary *userDict = [results objectForKey:@"user"];
				
				NSString *city = [userDict objectForKey:@"city"];
			
				// A default city has just been selected. Store it.
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				
				[defaults setObject:city forKey:kUserDefaultCityKey];
				
				skipLoginLanding = [defaults boolForKey:kSkipLoginLandingKey];
			} 
		}
		
		[jsonString release];
	}
	
	// Login credentials were given the tick of approval by the API
	// tell the delegate to animate this form out
	if (loginSuccess) {
		
		// Save Username/Password to NSUserDefaults
		[self saveAccountDetails];
		
		TAAppDelegate *appDelegate = [self appDelegate];
		
		// Store logged-in username
		[appDelegate setLoggedInUsername:self.usernameField.text];
		
		// We are now logged-in: update the iVar
		[appDelegate setUserLoggedIn:YES];
		
		
		// Determine whether we're going to skip the landing page
		// that would appear after the Login form. If so, 
		// go straight to the first section of the app.
		if (skipLoginLanding) { 
		
			appDelegate.window.rootViewController = appDelegate.tabBarController;
			appDelegate.tabBarController.selectedIndex = 0;
		}
		
		else {
			
			TALoginLandingVC *loginLandingVC = [[TALoginLandingVC alloc] initWithNibName:@"TALoginLandingVC" bundle:nil];
			[self.navigationController pushViewController:loginLandingVC animated:YES];
			[loginLandingVC release];
		}
	}
	
	else {
		
		NSString *errorMessage = @"There was an error logging you in. Please try again.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
															message:errorMessage
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	// Hide loading animation
	[self hideLoading];
	
	[loginFetcher release];
	loginFetcher = nil;
    
}


- (void)saveAccountDetails {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	// Save a flag to say that the accountID has been saved
	[defaults setBool:YES forKey:kAccountUsernameSavedKey];
	
	// Save the username that's currently been entered by the user
	// into the NSUserDefaults
	NSString *saveUsername = self.usernameField.text;
	[defaults setObject:saveUsername forKey:kSavedUsernameKey];
	
	// Save the password that's currently been entered by the user
	// into the NSUserDefaults
	NSString *savePassword = self.passwordField.text;
	[defaults setObject:savePassword forKey:kSavedPasswordKey];
}


- (void)retrievePreviousAccountDetails {

	// Retrieve saved accountID from user defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL idSaved = [defaults boolForKey:kAccountUsernameSavedKey];
    
    if (idSaved) {
        
        NSString *savedUsername = [defaults objectForKey:kSavedUsernameKey];
        self.usernameField.text = savedUsername;  
		
		NSString *savedPassword = [defaults objectForKey:kSavedPasswordKey];
        self.passwordField.text = savedPassword;
    }
}


- (void)logout {
    
    // Clear objects
    TAAppDelegate *appDelegate = [self appDelegate];
    
    // LOGOUT FROM SERVER?
    
    // Reset workordersLoaded
	[appDelegate setUserLoggedIn:NO];
    appDelegate.loggedInUsername = nil;
	appDelegate.sessionToken = nil;
    
    // Re-configure each tab's view controllers
    [(TAFeedVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0] willLogout];
    
    [(TAExploreVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:1] viewControllers] objectAtIndex:0] willLogout];
    
    [(TACameraVC *)[[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:2] viewControllers] objectAtIndex:0] willLogout];
	
    [(TANotificationsVC *)[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:3] topViewController] willLogout];
    
    [(TAProfileVC *)[(UINavigationController *)[appDelegate.tabBarController.viewControllers objectAtIndex:4] topViewController] willLogout];
	
    // Reset Window to display Login form
    appDelegate.window.rootViewController = self;
	
}


- (IBAction)forgottenPasswordButtonTapped:(id)sender { 

	TAForgottenPasswordVC *pswdVC = [[TAForgottenPasswordVC alloc] initWithNibName:@"TAForgottenPasswordVC" bundle:nil];
	
	[self.navigationController pushViewController:pswdVC animated:YES];
	[pswdVC release];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


@end
