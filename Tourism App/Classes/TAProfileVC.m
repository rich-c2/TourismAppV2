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
#import "TAImageGridVC.h"
#import "TAGuidesListVC.h"
#import "ImageManager.h"
#import "TALoginVC.h"
#import "TAMyContentVC.h"
#import "TASettingsVC.h"
#import "TASimpleListVC.h"
#import "TAFriendsVC.h"

@interface TAProfileVC ()

@end

@implementation TAProfileVC

@synthesize username, avatarURL, usernameLabel, photosBtn, nameLabel, avatarView;
@synthesize followUserBtn, followingUserBtn, followingBtn, followersBtn, myContentBtn, bioView;
@synthesize findFriendsBtn, contentScrollView, guidesBtn, cityLabel;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil observeLogin:(BOOL)observe {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
		// Listen for when the user has logged-in
		if (observe) [self initLoginObserver];
		
		self.title = @"Account";
    }
    return self;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Update username label
	if ([self.username length] > 0)
		[self.usernameLabel setText:self.username];
	
	[self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, (self.contentScrollView.frame.size.height * 1.5))];
}


- (void)viewDidUnload {
	
	self.avatarURL = nil;
	self.nameLabel = nil;
	self.username = nil;
	
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
	self.nameLabel = nil;
	[usernameLabel release];
	self.usernameLabel = nil;
	[avatarView release];
	self.avatarView = nil;
	[myContentBtn release];
	self.myContentBtn = nil;
    [findFriendsBtn release];
    self.findFriendsBtn = nil;
	
	[contentScrollView release];
	self.contentScrollView = nil;
	
	[guidesBtn release];
	self.guidesBtn = nil;
    [cityLabel release];
    cityLabel = nil;
	[bioView release];
	bioView = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	if ([self.username length] > 0){
	
		// Start fetching the Profile API
		// if we're not already loading it.
		if (!loading && !profileLoaded) { 
			
			[self showLoading];
			
			[self loadUserDetails];
		}
		
		// IF we're not already loading 
		// "isFollowing" API then start it
		if (!loadingIsFollowing && !isFollowingLoaded) {
			
			// IF the loggedIn User is look at his/her own profile
			// then disable the follow/unfollow buttons
			if (![self.username isEqualToString:[self appDelegate].loggedInUsername]) {
		
				[self detectFollowStatus];
			}
		}
		
		// FOR NOW: Add an "save" button to the top-right of the nav bar
		// if this is a guide NOT created by the logged-in user
		if ([self.username isEqualToString:[self appDelegate].loggedInUsername]) {
			
			
			[self.photosBtn setHidden:YES];
			[self.guidesBtn setHidden:YES];
			
			[self setupNavBar];
		}
		
		else {
			
			// HIDE MY CONTENT BUTTON
			self.myContentBtn.hidden = YES;
			self.findFriendsBtn.hidden = YES;
		}
	}
	
	[super viewWillAppear:animated];
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
	[usernameLabel release];
	[avatarView release];
	[myContentBtn release];
    [findFriendsBtn release];
	[contentScrollView release];
	[guidesBtn release];
    [cityLabel release];
    [cityLabel release];
    [cityLabel release];
	[bioView release];
    [super dealloc];
}


#pragma mark MY-METHODS

- (void)initLoginObserver {
	
	// Get an iVar of TAAppDelegate
	TAAppDelegate *appDelegate = [self appDelegate];
	
	/*
     Register to receive change notifications for the "userLoggedIn" property of
     the 'appDelegate' and specify that both the old and new values of "userLoggedIn"
     should be provided in the observe… method.
     */
    [appDelegate addObserver:self
						   forKeyPath:@"userLoggedIn"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSInteger loggedIn = 0;
	
    if ([keyPath isEqual:@"userLoggedIn"])
		loggedIn = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	
	if (loggedIn == 1) {
		
		[self setupNavBar];
		
		// Set the username for this profile
		// It equals the username of whoever just logged-in
		self.username = [self appDelegate].loggedInUsername;
		
		[self.usernameLabel setText:self.username];
		
		[self showLoading];
		
		[self loadUserDetails];
		
		[self.photosBtn setHidden:YES];
		[self.guidesBtn setHidden:YES];
		
		
		// Get an iVar of TAAppDelegate
		// and STOP observing the AppDelegate's userLoggedIn
		// property now that the user HAS logged-in
		//TAAppDelegate *appDelegate = [self appDelegate];
		//[appDelegate removeObserver:self forKeyPath:@"userLoggedIn"];
	}
	
	else if (loggedIn == 0) { 
	
		[self clearUIFields];
	}
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
	[followingVC setNavigationTitle:@"Following"];
	
	[self.navigationController pushViewController:followingVC animated:YES];
	[followingVC release];
}


- (IBAction)followersButtonTapped:(id)sender {
	
	// Push the followers VC onto the stack
	TAUsersVC *followersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[followersVC setSelectedUsername:self.username];
	[followersVC setManagedObjectContext:[[self appDelegate] managedObjectContext]];
	[followersVC setUsersMode:UsersModeFollowers];
	[followersVC setNavigationTitle:@"Followers"];
	
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
	NSString *methodName = [NSString stringWithString:@"Follow"];	
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
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		//NSLog(@"FOLLOW jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	// Follow API was successful
	if (success) {
		
		// Hide 'Follow' user button
		[self.followUserBtn setHidden:YES];
	
		// Display 'Following' user button
		[self.followingUserBtn setHidden:NO];
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
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		//NSLog(@"UNFOLLOW jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	// Follow API was successful
	if (success) {
		
		// Show 'Follow' user button
		[self.followUserBtn setHidden:NO];
		
		// Hide 'Following' user button
		[self.followingUserBtn setHidden:YES];
	}
		
	[unfollowFetcher release];
	unfollowFetcher = nil;
}


#pragma Profile methods

- (void)initProfileAPI {

	NSString *postString = [NSString stringWithFormat:@"username=%@", self.username];
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
	
	NSLog(@"PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		profileLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *newUserData = [results objectForKey:@"user"];
		
		NSLog(@"new user data:%@", newUserData);
		
		// Update name
		NSString *newFullName = [NSString stringWithFormat:@"%@ %@", [newUserData objectForKey:@"firstName"], [newUserData objectForKey:@"lastName"]]; 
		[self.nameLabel setText:[newUserData objectForKey:@"username"]];
		
		// Update username
		[self.nameLabel setText:newFullName];
		
		// Update followers and following buttons
		[self.followersBtn setTitle:[NSString stringWithFormat:@"%@ followers", [newUserData objectForKey:@"followers"]] forState:UIControlStateNormal];
		[self.followingBtn setTitle:[NSString stringWithFormat:@"%@ following", [newUserData objectForKey:@"following"]] forState:UIControlStateNormal];
		
		// Update photos button
		[self.photosBtn setTitle:[NSString stringWithFormat:@"My photos (%@)", [newUserData objectForKey:@"media"]] forState:UIControlStateNormal];
		
		// Load avatar image
		self.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [newUserData objectForKey:@"avatar"]];
		[self initAvatarImage:self.avatarURL];
		
		//Bio
		NSString *bioText = [newUserData objectForKey:@"bio"];
		if ([bioText length] > 0) self.bioView.text = bioText; 

		// CITY LABEL
		[self.cityLabel setText:[NSString stringWithFormat:@"City: %@", [newUserData objectForKey:@"city"]]];
	}
	
	// Hide loading view
	[self hideLoading];
	
	[profileFetcher release];
	profileFetcher = nil;
    
}


# pragma isFollowing methods

- (void)detectFollowStatus {
	
	loadingIsFollowing = YES;
	
	[self initIsFollowingAPI];
}


- (void)initIsFollowingAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&following=%@", [self appDelegate].loggedInUsername, self.username];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"isFollowing"];	
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
	
	NSLog(@"ISFOLLOWING DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == isFollowingFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loadingIsFollowing = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		isFollowingLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
	
		// Update UI to reflect the result of the API call
		NSString *result = [results objectForKey:@"following"];
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
	
	else [self.followUserBtn setHidden:NO];
}


- (IBAction)photosButtonTapped:(id)sender {

	// Push the following VC onto the stack
	TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[imageGridVC setUsername:self.username];
	
	[self.navigationController pushViewController:imageGridVC animated:YES];
	[imageGridVC release];
}


- (IBAction)guidesButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAGuidesListVC *guidesListVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesListVC setUsername:self.username];
	
	
	// Set the correct guides list 'mode'
	// IF the username = the user who is logged-in
	// then we're viewing "my guides", otherwise viewing 
	// someone else's guides
	if ([self.username isEqualToString:[self appDelegate].loggedInUsername]) 
		[guidesListVC setGuidesMode:GuidesModeMyGuides];
	else
		[guidesListVC setGuidesMode:GuidesModeViewing];
	
	
	[self.navigationController pushViewController:guidesListVC animated:YES];
	[guidesListVC release];
}


- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatarView.image) {
		
		NSLog(@"LOADING AVATAR IMAGE:%@", avatarURLString);
		
		[self.avatarView setBackgroundColor:[UIColor yellowColor]];
		NSURL *url = [avatarURLString convertToURL];
		
		UIImage* img = [ImageManager loadImage:url progressIndicator:nil];
		if (img) [self.avatarView setImage:img];
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([[self.avatarURL convertToURL] isEqual:url]) {
		
		NSLog(@"AVATAR IMAGE LOADED:%@", [url description]);
		
		[self.avatarView setImage:image];
	}
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)viewSettings:(id)sender {
	
	// Push the following VC onto the stack
	TASettingsVC *settingsVC = [[TASettingsVC alloc] initWithNibName:@"TASettingsVC" bundle:nil];
	[self.navigationController pushViewController:settingsVC animated:YES];
	[settingsVC release];
}


- (IBAction)myContentButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAMyContentVC *myContentVC = [[TAMyContentVC alloc] initWithNibName:@"TAMyContentVC" bundle:nil];
	[myContentVC setUsername:self.username];
	[self.navigationController pushViewController:myContentVC animated:YES];
	[myContentVC release];
}


- (IBAction)findFriendsButtonTapped:(id)sender {
	
	// Push the following VC onto the stack
	TAFriendsVC *friendsVC = [[TAFriendsVC alloc] initWithNibName:@"TAFriendsVC" bundle:nil];
	[self.navigationController pushViewController:friendsVC animated:YES];
	[friendsVC release];
}


- (void)willLogout {
	
	[self clearUIFields];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)setupNavBar {

	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"settings" style:UIBarButtonItemStyleDone target:self action:@selector(viewSettings:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	[buttonItem release];
}


- (void)clearUIFields {
	
	// Start 'observing' for when the user
	// logs in again 
	//[self initLoginObserver];

	self.username = nil;
	self.nameLabel.text = nil;
	self.myContentBtn.hidden = YES;
	self.findFriendsBtn.hidden = YES;
	[self.followersBtn setTitle:@"0 Followers" forState:UIControlStateNormal];
	[self.followingBtn setTitle:@"0 Following" forState:UIControlStateNormal];
	self.followingUserBtn.hidden = YES;
	self.followUserBtn.hidden = YES;
	
	self.avatarURL = nil;
	self.avatarView.image = nil;
	[self.photosBtn setTitle:@"Photos" forState:UIControlStateNormal];
}


		 
@end
