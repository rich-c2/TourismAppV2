//
//  TAProfileVC.m
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAProfileVC.h"
#import "TAAppDelegate.h"
#import "JSONFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "TAUsersVC.h"
//#import "User.h"

@interface TAProfileVC ()

@end

@implementation TAProfileVC

@synthesize username, avatarURL, photosBtn, nameLabel;
@synthesize followUserBtn, followingUserBtn, followingBtn, followersBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	[self initTestData];
}

- (void)viewDidUnload {
	
	self.nameLabel = nil;
	self.username = nil;
	self.avatarURL = nil;
	
	[followingUserBtn release];
	self.followingUserBtn = nil;
	
    [followUserBtn release];
    self.followUserBtn = nil;
	
    [followingBtn release];
    self.followingBtn = nil;
    [followersBtn release];
    self.followersBtn = nil;
	[photosBtn release];
	self.photosBtn = nil;
	[nameLabel release];
	nameLabel = nil;
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	// Start fetching the Profile API
	// if we're not already loading it.
	if (!loading && !profileLoaded) { 
		
		[self showLoading];
		
		[self loadUserDetails];
	}
	
	// IF we're not already loading 
	// "isFollowing" API then start it
	if (!loadingIsFollowing) {
	
		[self detectFollowStatus];
	}
	
	[super viewWillAppear:animated];
}


- (void)initTestData {

	// For now, set the username to be whoever is logged-in
	self.username = [self appDelegate].loggedInUsername;
}


- (IBAction)followingButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAUsersVC *followingVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[followingVC setSelectedUsername:self.username];
	[followingVC setManagedObjectContext:[[self appDelegate] managedObjectContext]];
	[followingVC setUsersMode:UsersModeFollowing];
	
	[self.navigationController pushViewController:followingVC animated:YES];
	[followingVC release];
}


- (IBAction)followersButtonTapped:(id)sender {
	
	// Push the followers VC onto the stack
	TAUsersVC *followersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[followersVC setSelectedUsername:self.username];
	[followersVC setManagedObjectContext:[[self appDelegate] managedObjectContext]];
	[followersVC setUsersMode:UsersModeFollowers];
	
	[self.navigationController pushViewController:followersVC animated:YES];
	[followersVC release];
}


- (IBAction)followUserButtonTapped:(id)sender {

	// Initiate Follow API
	[self initFollowAPI];
}


- (IBAction)followingUserButtonTapped:(id)sender {

	// Initiate Unfollow API
	[self initUnfollowAPI];
}


#pragma Follow/Unfollow methods

- (void)loadUserDetails {
	
	loading = YES;
	
	// Make API call for User details
	[self initProfileAPI];
}


- (void)initFollowAPI {
	
	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", self.username, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Unfollow"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	followFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													 receiver:self
													   action:@selector(receivedFollowResponse:)];
	[followFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == followFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//loading = NO;
	//feedLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) { 
			
			/*
			 User *loggedInUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:self.managedObjectContext];
			 
			 // Add/Remove to/from logged-in User's following set/array
			 if (followingUser) {
			 
			 [loggedInUser removeFollowingObject:self.selectedUser];			
			 self.selectedUser.followersCount = [NSNumber numberWithInt:[self.selectedUser.followersCount intValue] - 1];
			 }
			 else {
			 
			 [loggedInUser addFollowingObject:self.selectedUser];
			 self.selectedUser.followersCount = [NSNumber numberWithInt:[self.selectedUser.followersCount intValue] + 1];
			 }
			 
			 // Update the followers and following labels
			 [self updateFollowCounts];
			 
			 // Toggle the 'follow status' of the user we're viewing
			 [self toggleFollowStatus];*/
		}
		
		//NSLog(@"jsonString:%@", jsonString);
		
		//[jsonString release];
	}
	
	[followFetcher release];
	followFetcher = nil;
}


- (void)initUnfollowAPI {

	NSString *postString = [NSString stringWithFormat:@"following=%@&follower=%@&token=%@", self.username, [self appDelegate].loggedInUsername, [self appDelegate].sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Unfollow"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	unfollowFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													receiver:self
													  action:@selector(receivedUnfollowResponse:)];
	[unfollowFetcher start];
}


// Example fetcher response handling
- (void)receivedUnfollowResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == unfollowFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//loading = NO;
	//feedLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) { 
			
			/*
			User *loggedInUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:self.managedObjectContext];
			
			// Add/Remove to/from logged-in User's following set/array
			if (followingUser) {
				
				[loggedInUser removeFollowingObject:self.selectedUser];			
				self.selectedUser.followersCount = [NSNumber numberWithInt:[self.selectedUser.followersCount intValue] - 1];
			}
			else {
				
				[loggedInUser addFollowingObject:self.selectedUser];
				self.selectedUser.followersCount = [NSNumber numberWithInt:[self.selectedUser.followersCount intValue] + 1];
			}
			
			// Update the followers and following labels
			[self updateFollowCounts];
			
			// Toggle the 'follow status' of the user we're viewing
			[self toggleFollowStatus];*/
		}
		
		//NSLog(@"jsonString:%@", jsonString);
		
		//[jsonString release];
		
	}
	
	[unfollowFetcher release];
	unfollowFetcher = nil;
}


#pragma Profile methods

- (void)initProfileAPI {

	NSString *postString = [NSString stringWithFormat:@"username=%@", @"rich"];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Profile"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	profileFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													receiver:self
											   action:@selector(receivedProfileResponse:)];
	[profileFetcher start];
}


// Example fetcher response handling
- (void)receivedProfileResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	profileLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *newUserData = [results objectForKey:@"user"];
		
		// Update the current User object with the details
		self.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [newUserData objectForKey:@"avatar"]];
		
		// Update name
		NSString *newFullName = [NSString stringWithFormat:@"%@ %@", [newUserData objectForKey:@"firstName"], [newUserData objectForKey:@"lastName"]]; 
		[self.nameLabel setText:newFullName];
		
		// Update followers and following buttons
		[self.followersBtn setTitle:[NSString stringWithFormat:@"%@ followers", [newUserData objectForKey:@"followers"]] forState:UIControlStateNormal];
		[self.followingBtn setTitle:[NSString stringWithFormat:@"%@ following", [newUserData objectForKey:@"following"]] forState:UIControlStateNormal];
		
		// Update photos button
		[self.photosBtn setTitle:[NSString stringWithFormat:@"My photos (%@)", [newUserData objectForKey:@"media"]] forState:UIControlStateNormal];
		 
		// Update guides button - API tweak required
		
	}
	
	// Hide loading view
	[self hideLoading];
	
	[profileFetcher release];
	profileFetcher = nil;
    
}


# pragma isFollowing methods

- (void)detectFollowStatus {
	
	// Detect if the user who's profile we're viewing is within the logged-in user's
	// following array/set
	/*User *loggedInUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:self.managedObjectContext];
	followingUser = [loggedInUser.following containsObject:self.selectedUser];
	
	// Filter the latest images that were downloaded from the Latest API
	NSArray *filteredFollowing = [loggedInUser.following filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username = %@", self.username]];
	
	NSString *buttonTitle = ((followingUser) ? @"Unfollow" : @"Follow");
	[self.followUserBtn setTitle:buttonTitle forState:UIControlStateNormal];*/
	
	loadingIsFollowing = YES;
	
	[self initIsFollowingAPI];
}


- (void)initIsFollowingAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&following=", [self appDelegate].loggedInUsername, self.username];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Profile"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	isFollowingFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													receiver:self
													  action:@selector(receivedIsFollowingResponse:)];
	[isFollowingFetcher start];
}


// Example fetcher response handling
- (void)receivedIsFollowingResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == isFollowingFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	profileLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		NSString *result = [results objectForKey:@"following"];
	
		// Enable
		[self updateFollowingButton:result];
	}
	
	// Hide loading view
	[self hideLoading];
	
	[isFollowingFetcher release];
	isFollowingFetcher = nil;
}


- (void)updateFollowingButton:(NSString *)isFollowing {

	// Enable the correct button
	// If this use is being followed by the logged-in user
	// then show the followingUser button. And vice-versa.
	if ([isFollowing isEqualToString:@"true"])
		[self.followingUserBtn setHidden:NO];
	else
		[self.followUserBtn setHidden:NO];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)dealloc {
	
	[followingUserBtn release];
	[avatarURL release];
	[nameLabel release];
	[photosBtn release];
	[username release];
    [followUserBtn release];
    [followingBtn release];
    [followersBtn release];
    [super dealloc];
}

		 
@end
