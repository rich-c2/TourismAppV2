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
@synthesize followUserBtn, followingBtn, followersBtn;

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
}

- (void)viewDidUnload {
	
	self.nameLabel = nil;
	self.username = nil;
	self.avatarURL = nil;
	
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
	
	[super viewWillAppear:animated];
}


- (void)loadUserDetails {

	// Make API call for User details
	[self initProfileAPI];
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
	
	NSLog(@"PROFILE DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == profileFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	loading = NO;
	profileLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
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


- (void)detectFollowStatus {
	
	// Detect if the user who's profile we're viewing is within the logged-in user's
	// following array/set
	/*User *loggedInUser = [User userWithUsername:[self appDelegate].loggedInUsername inManagedObjectContext:self.managedObjectContext];
	followingUser = [loggedInUser.following containsObject:self.selectedUser];
	
	// Filter the latest images that were downloaded from the Latest API
	NSArray *filteredFollowing = [loggedInUser.following filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"username = %@", self.username]];
	
	NSString *buttonTitle = ((followingUser) ? @"Unfollow" : @"Follow");
	[self.followUserBtn setTitle:buttonTitle forState:UIControlStateNormal];*/
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)dealloc {
	
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
