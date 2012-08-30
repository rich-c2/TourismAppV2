//
//  TACreateGuideVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACreateGuideVC.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "JSONFetcher.h"
#import "TAAppDelegate.h"
#import "TAUsersVC.h"

@interface TACreateGuideVC ()

@end

@implementation TACreateGuideVC

@synthesize imageCode, titleField, guideTagID, guideCity, recommendToUsernames;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
    }
    return self;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
}

- (void)viewDidUnload {
	
	[titleField release];
	self.titleField = nil;
	
	self.imageCode = nil;
	self.recommendToUsernames = nil;
	
	self.guideTagID = nil; 
	self.guideCity = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[recommendToUsernames release];
	[guideTagID release]; 
	[guideCity release];

	[imageCode release];
	[titleField release];
	[super dealloc];
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {

	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	self.recommendToUsernames = usernames;
}


#pragma mark - UITextField delegations
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    // If the current text field is the guide title - remove the keyboard
	if (textField == self.titleField)
		[self.titleField resignFirstResponder];
    
    return YES;
}


// The submit button was tapped by the user
// This will trigger the "addguide" API call
- (IBAction)submitButtonTapped:(id)sender {

	// init the "addguide" API call
	[self initAddGuideAPI];
}


- (void)initAddGuideAPI {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *title = self.titleField.text;
	NSString *city = self.guideCity;
	NSInteger tagID = [self.guideTagID intValue];
	NSString *imageIDs = self.imageCode;
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&title=%@&city=%@&tag=%i&imageIDs=%@&private=0&token=%@", username, title, city, tagID, imageIDs, [self appDelegate].sessionToken];
	
	NSLog(@"ADD GUIDE DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"addguide"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	fetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedAddGuideResponse:)];
	[fetcher start];
}


// Example fetcher response handling
- (void)receivedAddGuideResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"SAVE RESPONSE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == fetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// New image data;
	NSDictionary *guideData;
	BOOL submissionSuccess;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			submissionSuccess = YES;
			
			guideData = [results objectForKey:@"guide"];
		}
		
		[jsonString release];
	}
	
	NSString *responseMessage;
	NSString *responseTitle = ((submissionSuccess) ? @"Success!" : @"Sorry!");
	
	// If the submission was successful
	if (submissionSuccess) responseMessage = @"Your guide was successfully saved.";
	else responseMessage = @"There was an error saving your guide.";
	
	
	// FOR NOW: Kick off the "Recommend" API on the back of this one.
	// These two function will probably have to be combined
	if (submissionSuccess && [self.recommendToUsernames count] > 0) {
	
		[self initRecommendAPI:[guideData objectForKey:@"guideID"]];
	}
	
	
	// Show pop up for submission result
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:responseTitle
														message:responseMessage
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
	
	// Create Image object and store
	if (submissionSuccess) {
		
		// Pop to root view controller (photo picker/camera)
		//[self.navigationController popToRootViewControllerAnimated:YES];
	}
	
	// Clean up
	[fetcher release];
	fetcher = nil;
    
}


- (void)initRecommendAPI:(NSString *)guideID {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *usernames = [self.recommendToUsernames componentsJoinedByString:@","];
	
	NSString *postString = [NSString stringWithFormat:@"type=guide&username=%@&code=%@&usernames=%@&token=%@", username, guideID, usernames, [self appDelegate].sessionToken];
	
	NSLog(@"ADD GUIDE DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"recommend"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	recommendFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedRecommendResponse:)];
	[recommendFetcher start];
}


// Example fetcher response handling
- (void)receivedRecommendResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"RECOMMEND RESPONSE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == recommendFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// New image data;
	//NSDictionary *guideData;
	//BOOL submissionSuccess;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			//submissionSuccess = YES;
			
			//guideData = [results objectForKey:@"guide"];
		}
		
		[jsonString release];
	}
	
	
	// Hide loading animation
	[self hideLoading];
	
	// Clean up
	[recommendFetcher release];
	recommendFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (IBAction)recommendButtonTapped:(id)sender {

	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
	[usersVC release];
}


@end
