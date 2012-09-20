//
//  TARegisterVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TARegisterVC.h"
#import "TAAppDelegate.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "JSONKit.h"
#import "JSONFetcher.h"
#import "Constants.h"

#define MAIN_CONTENT_HEIGHT 200

static NSString *kAccountUsernameSavedKey = @"accountUsernameSavedKey";
static NSString *kSavedUsernameKey = @"savedUsernameKey";
static NSString *kSavedPasswordKey = @"savedPasswordKey";
static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TARegisterVC ()

@end

@implementation TARegisterVC

@synthesize nameField, emailField;
@synthesize usernameField, passwordField, formScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
	// Set up custom nav bar
	[self initNavBar];
	
	// register scroll view content size
	CGSize newSize = CGSizeMake(self.formScrollView.frame.size.width, (self.formScrollView.frame.size.height * 1.1));
	[self.formScrollView setContentSize:newSize];
	
	// Focus on name field
	[self.nameField becomeFirstResponder];
	
    [super viewDidLoad];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    [nameField release];
    nameField = nil;
    [emailField release];
    emailField = nil;
    [usernameField release];
    usernameField = nil;
    [passwordField release];
    passwordField = nil;
	
	[formScrollView release];
	formScrollView = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
    [nameField release];
    [emailField release];
    [usernameField release];
    [passwordField release];
	[formScrollView release];
    [super dealloc];
}


#pragma mark - UITextField delegations

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	// Reset the height of the Table's frame
	CGRect newTableFrame = self.formScrollView.frame;
	newTableFrame.size.height = (367.0 - (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT));
	[self.formScrollView setFrame:newTableFrame];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	if (textField == self.passwordField) {
		
		// Adjust searchTable's frame height
		CGRect newFrame = self.formScrollView.frame;
		newFrame.size.height = MAIN_CONTENT_HEIGHT;
		[self.formScrollView setFrame:newFrame];
		
		// Hide the keyboard
        [textField resignFirstResponder];
		
		// REgister the user
		[self initRegisterAPI];
	}
	
	else {
		
		UITextField *newField = (UITextField *)[self.view viewWithTag:(textField.tag + 1)];
		[newField becomeFirstResponder];
	}
    
    return YES;
}


- (void)initRegisterAPI {
	
	[self showLoading];
	
	
	/* 
		NOTE!
		PASSING NAMEFIELD.TEXT FOR BOTH FIRST NAME AND LAST NAME
		PARAMETERS FOR THE REGISTER API CALL - THIS MUST CHANGE
	 */
	
	NSString *jsonString = [NSString stringWithFormat:@"firstname=%@&lastname=%@&emailaddress=%@&username=%@&password=%@", self.nameField.text, self.nameField.text, self.emailField.text, self.usernameField.text, self.passwordField.text];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
    
    // Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Register"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];  
	
	// JSONFetcher
    registerFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedRegisterResponse:)];
    [registerFetcher start];
}


// Example fetcher response handling
- (void)receivedRegisterResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == registerFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL registrationSuccess = NO;
	
	//NSDictionary *userData;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		for (int i = 0; i < [[results allKeys] count]; i++) {
			
			NSString *key = [[results allKeys] objectAtIndex:i];
			NSString *value = [results objectForKey:key];
			
			if ([key isEqualToString:@"result"]) registrationSuccess = (([value isEqualToString:@"ok"]) ? YES : NO);
			
			// Pass the token value to the AppDelegate to be stored as 
			// the session token for all API calls
			else if ([key isEqualToString:@"token"]) [[self appDelegate] setToken:[results objectForKey:key]];
			
			// Store the user data in a dictionary to pass to the delegate
			//else if ([key isEqualToString:@"user"]) userData = [results objectForKey:key];
		}
		
		NSLog(@"REGISTRATION RESULTS:%@", results);
		
		[jsonString release];
	}
	
	// Registration details were given the tick of approval by the API
	// tell the delegate to animate this form out and store 
	// the username that was entered by the user
	if (registrationSuccess) {
		
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
	}
	
	else {
		
		NSString *errorMessage = @"There was an error registering your account. Please try again.";
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!"
															message:errorMessage
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	[self hideLoading];
	
	[registerFetcher release];
	registerFetcher = nil;
    
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


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initNavBar {

	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {

	[self.navigationController popViewControllerAnimated:YES];
}


@end
