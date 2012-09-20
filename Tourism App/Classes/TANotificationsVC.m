//
//  TANotificationsVC.m
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TANotificationsVC.h"
#import "TAAppDelegate.h"
#import "StringHelper.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "TANotificationsManager.h"
#import "TAProfileVC.h"
#import "TAImageDetailsVC.h"
#import "AsyncCell.h"
#import "TAGuideDetailsVC.h"

@interface TANotificationsVC ()

@end

@implementation TANotificationsVC

@synthesize reccomendations, meItems, following, recommendationsTable, tabsControl;
@synthesize notifications;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		self.title = @"Notifications";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Setup nav bar
	[self initNavBar];
	
	// Set tap action for segmented control buttons
	[self.tabsControl addTarget:self
						 action:@selector(initGetNotificationsAPI)
			   forControlEvents:UIControlEventValueChanged];
	
	self.notifications = [NSMutableArray array];

	// Update unread counts on each of the three notifications tabs
	TANotificationsManager *manager = [TANotificationsManager sharedManager];
	[self.tabsControl setTitle:[NSString stringWithFormat:@"Rec. (%i)", manager.recommends.intValue] forSegmentAtIndex:0];
	[self.tabsControl setTitle:[NSString stringWithFormat:@"ME (%i)", manager.meItems.intValue] forSegmentAtIndex:1];
}

- (void)viewDidUnload {
	
	[recommendationsTable release];
	self.recommendationsTable = nil;
	
	[tabsControl release];
	self.tabsControl = nil;
	
	self.notifications = nil;
	self.meItems = nil; 
	self.following = nil;
	self.reccomendations = nil;
	self.meItems = nil;
	self.following = nil;
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {

	[notifications release];
	[meItems release];
	[following release];
	[reccomendations release];
	[recommendationsTable release];
	[tabsControl release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (!loading && !recommendationsLoaded) { 
		
		[self showLoading];
		
		[self initGetNotificationsAPI];
	}
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.notifications count];
}


- (void)configureCell:(AsyncCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *notification = [self.notifications objectAtIndex:[indexPath row]];
	
	NSString *title = [notification objectForKey:@"title"];
	NSString *subtitle = [notification objectForKey:@"subtitle"];
	NSString *avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [notification objectForKey:@"thumb"]];
	 
	[cell updateCellWithUsername:title withName:subtitle imageURL:avatarURL];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	AsyncCell *cell = (AsyncCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[AsyncCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *notification = [self.notifications objectAtIndex:[indexPath row]];
	
	// Find the type of notification we're dealing with
	NSString *type = [notification objectForKey:@"type"];
	
	
	if ([type isEqualToString:@"media"]) {
	
		// Push the Image Details VC onto the stack
		TAImageDetailsVC *imageDetailsVC = [[TAImageDetailsVC alloc] initWithNibName:@"TAImageDetailsVC" bundle:nil];
		[imageDetailsVC setImageCode:[notification objectForKey:@"code"]];
		
		[self.navigationController pushViewController:imageDetailsVC animated:YES];
		[imageDetailsVC release];
	}
	
	else if ([type isEqualToString:@"user"]) {
	
		// Push the User Profile VC onto the stack
		TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
		[profileVC setUsername:[notification objectForKey:@"code"]];
		[self.navigationController pushViewController:profileVC animated:YES];
		[profileVC release];
	}
	
	else if ([type isEqualToString:@"guide"]) {
		
		// Push the User Profile VC onto the stack
		// Tell the VC what Guide is in question (GuideID) and what mode
		// we are viewing the guide details in. It is not our guide so we are
		// in GuideModeViewing
		TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
		[guideDetailsVC setGuideID:[notification objectForKey:@"code"]];
		[guideDetailsVC setGuideMode:GuideModeViewing];
		
		[self.navigationController pushViewController:guideDetailsVC animated:YES];
		[guideDetailsVC release];
	}
}


- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


/* This function calls the "getnotifications" API 
   The API will return how many new/unreceived notifications
   have been registered in the CMS for this user. It takes one parameter: a category
   string which dictates whether the API will fetch ME, recommendations or following
   notifications.
*/	
- (void)initRecommendationsAPI {
	
	NSString *type = @"me";
	
	NSInteger page = 1;
	NSInteger size = 5;
	//&pg=%i&sz=%i
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&category=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], type];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"getnotifications"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	recommendationsFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedRecommendationsResponse:)];
	[recommendationsFetcher start];
}



/*	This function calls the "getnotifications" API 
	The API will return how many new/unreceived notifications
	have been registered in the CMS for this user. It takes one parameter: a category
	string which dictates whether the API will fetch ME, recommendations or following
	notifications.
*/	
- (void)initGetNotificationsAPI {
	
	NSString *category = [self getSelectedCategory];
		
	//NSInteger page = 1;
	//NSInteger size = 5;
	//&pg=%i&sz=%i
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&category=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], category];
	
	NSLog(@"postString:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"getnotifications"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryRecommendations) {
		
		recommendationsFetcher = [[JSONFetcher alloc] initWithURLRequest:request
																receiver:self action:@selector(receivedRecommendationsResponse:)];
		[recommendationsFetcher start];
	}
	
	else if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryMe) {
		
		meFetcher = [[JSONFetcher alloc] initWithURLRequest:request
																receiver:self action:@selector(receivedMeResponse:)];
		[meFetcher start];
	}
	
	else if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryFollowing) {
		
		followingFetcher = [[JSONFetcher alloc] initWithURLRequest:request
																receiver:self action:@selector(receivedFollowingResponse:)];
		[followingFetcher start];
	}
}


// Example fetcher response handling
- (void)receivedRecommendationsResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == recommendationsFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING RECOMMENDATIONS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		self.reccomendations = [results objectForKey:@"notifications"];
	}
	
	// If the ME tab is currently selected then update the UI
	if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryRecommendations) {
		
		// Get the main array (self.notifications) to point
		// to the reccomendations array
		self.notifications = self.reccomendations;
		
		// Update table
		[self.recommendationsTable reloadData];
	}
	
	[self hideLoading];
	
	[recommendationsFetcher release];
	recommendationsFetcher = nil;
}


- (void)receivedMeResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == meFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING RECOMMENDATIONS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		self.meItems = [results objectForKey:@"notifications"];
	}
	
	
	// Stop showing the loading animation
	[self hideLoading];
	
	// If the ME tab is currently selected then update the UI
	if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryMe) {
	
		// Get the main array (self.notifications) to point
		// to the meItems array
		self.notifications = self.meItems;
		
		// Update table
		[self.recommendationsTable reloadData];
	}
	
	[meFetcher release];
	meFetcher = nil;
}


- (void)receivedFollowingResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == followingFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING FOLLOWING:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		self.following = [results objectForKey:@"notifications"];
	}
	
	
	// Stop showing the loading animation
	[self hideLoading];
	
	// If the ME tab is currently selected then update the UI
	if (self.tabsControl.selectedSegmentIndex == NotificationsCategoryFollowing) {
		
		// Get the main array (self.notifications) to point
		// to the meItems array
		self.notifications = self.following;
		
		// Update table
		[self.recommendationsTable reloadData];
	}
	
	[followingFetcher release];
	followingFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


/*
	This function returns a string representing what notification
	category is currently selected. At the minute it bases this on
	what tab is selected in the UISegmentControl.
*/
- (NSString *)getSelectedCategory {
	
	NSString *category;
	
	switch (self.tabsControl.selectedSegmentIndex) {
			
		case NotificationsCategoryRecommendations:
			category = @"recommendations";
			break;
			
		case NotificationsCategoryMe:
			category = @"me";
			break;
			
		case NotificationsCategoryFollowing:
			category = @"following";
			break;
			
		default:
			category = @"recommendations";
			break;
	}
	
	return category;
}



- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}



@end
