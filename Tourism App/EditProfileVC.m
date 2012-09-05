//
//  EditProfileVC.m
//  GiftHype
//
//  Created by Richard Lee on 15/05/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "EditProfileVC.h"
#import "TAAppDelegate.h"
#import "User.h"
#import "StringHelper.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "Constants.h"

#define MAIN_CONTENT_HEIGHT 367

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface EditProfileVC ()

@end

@implementation EditProfileVC

@synthesize managedObjectContext, formScrollView, currentTextField;
@synthesize firstNameField, lastNameField, emailField, cityBtn, selectedCity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	CGSize newSize = CGSizeMake(self.formScrollView.frame.size.width, self.formScrollView.frame.size.height);
	[self.formScrollView setContentSize:newSize];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.selectedCity = nil;
	self.managedObjectContext = nil;
	
	self.formScrollView = nil;
	
	self.firstNameField = nil;
	self.lastNameField = nil;
	self.emailField = nil;
	
	self.currentTextField = nil;
	
	[cityBtn release];
	cityBtn = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[selectedCity release];
	[managedObjectContext release];
	
	[formScrollView release];
	
	[currentTextField release];

	[firstNameField release]; 
	[lastNameField release]; 
	[emailField release];
	
	[cityBtn release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	if (!loading && !profileLoaded) {
		
		[self showLoading];
		
		[self fetchProfileDetails];
	}

}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	// Assign this text field as the new 'current' text field
	self.currentTextField = textField;
	
	// Reset the height of the Table's frame
	CGRect newTableFrame = self.formScrollView.frame;
	newTableFrame.size.height = (MAIN_CONTENT_HEIGHT - (KEYBOARD_HEIGHHT - TAB_BAR_HEIGHT));
	[self.formScrollView setFrame:newTableFrame];
	
	// Shift the scroll view's offset
	//CGPoint newOffset = CGPointMake(self.contentScrollView.contentOffset.x, 120.0);
	//[self.contentScrollView setContentOffset:newOffset animated:YES];
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	// Submit comment to the API
	if (self.currentTextField == self.emailField) {
		
		// Adjust searchTable's frame height
		CGRect newFrame = self.formScrollView.frame;
		newFrame.size.height = MAIN_CONTENT_HEIGHT;
		[self.formScrollView setFrame:newFrame];
		
		// Hide keyboard
		[self.currentTextField resignFirstResponder];
	}
	
	else {
		
		// Using the text field tag - retrieve the next field in the form 
		// and make it the first responder
		UITextField *nextField = (UITextField *)[self.formScrollView viewWithTag:(textField.tag+1)];
		[nextField becomeFirstResponder];
	}
    
    return YES;
}


#pragma CitiesDelegate

- (void)locationSelected:(NSDictionary *)city {
	
	self.selectedCity = [city objectForKey:@"city"];
	
	[self.cityBtn setTitle:self.selectedCity forState:UIControlStateNormal];
}


- (IBAction)saveButtonTapped:(id)sender {
	
	// Adjust searchTable's frame height
	CGRect newFrame = self.formScrollView.frame;
	newFrame.size.height = MAIN_CONTENT_HEIGHT;
	[self.formScrollView setFrame:newFrame];
	
	// Hide the keyboard
	[self.currentTextField resignFirstResponder];
	
	// Show loading animation
	[self showLoading];

	// Assemble relevant data from the text fields ////////////////////////////////////
	NSString *firstName = self.firstNameField.text;
	NSString *lastName = self.lastNameField.text;
	NSString *email = self.emailField.text;
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&firstname=%@&lastname=%@&emailaddress=%@&city=%@&token=%@", [self appDelegate].loggedInUsername, firstName, lastName, email, self.selectedCity, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"UpdateProfile"];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_ADDRESS, methodName];
	
	// Print the URL to the console
	NSLog(@"URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	updateProfileFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													receiver:self action:@selector(receivedUpdateProfileResponse:)];
	[updateProfileFetcher start];
	
	////////////////////////////////////////////////////////////////////////////////
}


// Example fetcher response handling
- (void)receivedUpdateProfileResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"UPDATE PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == updateProfileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// If the request was successful
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
		
			// A default city has just been selected. Store it.
			if ([self.selectedCity length] > 0) 
				[[NSUserDefaults standardUserDefaults] setObject:self.selectedCity forKey:kUserDefaultCityKey];
		}

		[jsonString release];
	}
	
	// Hide loading view
	[self hideLoading];
	
	[updateProfileFetcher release];
	updateProfileFetcher = nil;
    
}


- (void)fetchProfileDetails {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@", [self appDelegate].loggedInUsername];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Profile"];
	NSString *urlString = [NSString stringWithFormat:@"%@%@", API_ADDRESS, methodName];
	
	// Print the URL to the console
	NSLog(@"URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	profileFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self action:@selector(receivedProfileResponse:)];
	[profileFetcher start];
}


// Example fetcher response handling
- (void)receivedProfileResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	profileLoaded = YES;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *newUserData = [results objectForKey:@"user"];
		
		self.firstNameField.text = [newUserData objectForKey:@"firstName"];
		self.lastNameField.text = [newUserData objectForKey:@"lastName"];
		self.emailField.text = [newUserData objectForKey:@"email"];
		
		self.selectedCity = [newUserData objectForKey:@"city"];
		if ([self.selectedCity length] > 0) 
			[self.cityBtn setTitle:self.selectedCity forState:UIControlStateNormal];
	}
	
	// Hide loading view
	[self hideLoading];
	
	[profileFetcher release];
	profileFetcher = nil;
    
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (IBAction)selectCityButtonTapped:(id)sender {
	
	TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
	[citiesListVC setDelegate:self];
	
	[self.navigationController pushViewController:citiesListVC animated:YES];
	[citiesListVC release];
}


@end
