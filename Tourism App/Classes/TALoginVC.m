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

static NSString *kAccountUsernameSavedKey = @"accountUsernameSavedKey";
static NSString *kSavedUsernameKey = @"savedUsernameKey";
static NSString *kSavedPasswordKey = @"savedPasswordKey";
static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

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


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is username - put the focus on the password field
	if (textField == self.usernameField)
		[self.passwordField becomeFirstResponder];
	
    else if (textField == self.passwordField) {
		
		// Hide the keyboard
        [textField resignFirstResponder];
		
        // Login the user
        [self login];
	}
    
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}


#pragma MY-METHODS

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
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
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
				[[NSUserDefaults standardUserDefaults] setObject:city forKey:kUserDefaultCityKey];
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
		
		// Show tab bar view controllers
        appDelegate.window.rootViewController = appDelegate.tabBarController;
        appDelegate.tabBarController.selectedIndex = 0;
		
		// Tell the delegate that we're logged-in now
		//[self.delegate loginSuccessful:nil];
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
	//[self hideLoading];
	
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


@end
