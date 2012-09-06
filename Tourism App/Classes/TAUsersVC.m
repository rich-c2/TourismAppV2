//
//  TAUsersVC.m
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUsersVC.h"
#import	"SVProgressHUD.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "TAProfileVC.h"
#import "TAAppDelegate.h"
#import "AsyncCell.h"

@interface TAUsersVC ()

@end

@implementation TAUsersVC

@synthesize usersMode, navigationTitle, delegate, searchField;
@synthesize usersTable, selectedUsername, users, managedObjectContext;

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
    
	// Set the title of this view controller
	self.title = self.navigationTitle;
	
	if (self.usersMode == UsersModeRecommendTo) {
		
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(saveSelections:)];
		buttonItem.target = self;
		self.navigationItem.rightBarButtonItem = buttonItem;
		[buttonItem release];
	}
	
	
	// If the mode is UsersModeSearchUsers
	// then we need to show the search bar
	if (self.usersMode == UsersModeSearchUsers) {
		
		self.searchField.hidden = NO;
		
		CGFloat barHeight = self.searchField.frame.size.height;
		
		// Adjust the position of the table
		CGRect frame = self.usersTable.frame;
		frame.origin.y += barHeight;
		frame.size.height -= barHeight;
		[self.usersTable setFrame:frame];
	}
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	[searchField release];
	self.searchField = nil;
	
    [super viewDidUnload];
    
	self.navigationTitle = nil;
	self.usersTable	= nil;
	self.selectedUsername = nil;
	self.users = nil;
	self.managedObjectContext = nil;

}

- (void)dealloc {
	
	[navigationTitle release];
	[usersTable release];
	[selectedUsername release];
	[users release];
	[managedObjectContext release];
	[searchField release];
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewWillAppear:animated];
	
	if (!usersLoaded && !loading) {
		
		loading = YES;
		
		// Show loading animation
		[self showLoading];
		
		switch (self.usersMode) {
				
			case UsersModeFollowing:
				[self initFollowingAPI];
				break;
			
			case UsersModeFollowers:
				[self initFollowersAPI];
				break;
				
			case UsersModeRecommendTo:
				[self.usersTable setAllowsMultipleSelection:YES];
				[self initFollowersAPI];
				break;
				
			case UsersModeFindViaFB:
				[self initFBFriendsAPI];
				break;
				
			default:
				loading = NO;
				[self hideLoading];
				break;
		}
	}
}


#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	// Hide keyboard
	[self.searchField resignFirstResponder];
	
	// Call "FindUser" API
	if (!loading) [self initFindUserAPI];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.users count];
}


- (void)configureCell:(AsyncCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSString *name;
	NSString *username;
	NSString *avatarURL;
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
	
	
	// FOR NOW - account for the fact that FindUser returns
	// a set of Users in a different format
	/*if (self.usersMode == UsersModeSearchUsers) {
	
		NSDictionary *userData = [user objectForKey:@"user"];
		
		name = [NSString stringWithFormat:@"%@ %@", [userData objectForKey:@"firstName"], [userData objectForKey:@"lastName"]];
		username = [userData objectForKey:@"username"];
		avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [userData objectForKey:@"avatar"]];
	}
	
	else {*/
		
		name = [user objectForKey:@"name"];
		
		username = [user objectForKey:@"username"];
		avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [user objectForKey:@"avatar"]];
	//}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	
	[cell updateCellWithUsername:username withName:name imageURL:avatarURL];
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
	
	/*if (self.usersMode == UsersModeRecommendTo) {
	
		AsyncCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		
		cell.c
	}*/
	
	if (self.usersMode != UsersModeRecommendTo) {
		
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
		
		NSString *username;
		
		// The FindUser API returns a different structure of JSON
		// so we have to access the "username" a different way
		/*if (self.usersMode == UsersModeSearchUsers) {
			
			NSDictionary *userData = [user objectForKey:@"user"];
			username = [userData objectForKey:@"username"];
		}
		
		else {*/
			
			username = [user objectForKey:@"username"];
		//}
		
		TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
		[profileVC setUsername:username];
		
		[self.navigationController pushViewController:profileVC animated:YES];
		[profileVC release];
	}
	
	else {
		
		AsyncCell *cell = (AsyncCell *)[tableView cellForRowAtIndexPath:indexPath];
		
		[cell setSelected:YES];
	}
}


#pragma MY-METHODS

- (void)initFollowingAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.selectedUsername, page, batchSize];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Following"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	usersFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedFollowingResponse:)];
	[usersFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowingResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == usersFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//NSLog(@"PRINTING FOLLOWING:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newFollowers = (NSMutableArray *)[results objectForKey:@"users"];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newFollowers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		[alphaDesc release];
		
		self.users = newFollowers;
		
		// clean up
		[jsonString release];
		
		// We've finished loading the artists
		usersLoaded = YES;
    }
	
	// Reload table
	[self.usersTable reloadData];
	
	[self hideLoading];
    
    [usersFetcher release];
    usersFetcher = nil;
}


- (void)initFollowersAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.selectedUsername, page, batchSize];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Followers"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	usersFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedFollowersResponse:)];
	[usersFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowersResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == usersFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
		
	NSLog(@"PRINTING FOLLOWERS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newFollowers = (NSMutableArray *)[results objectForKey:@"users"];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newFollowers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];	
		[alphaDesc release];
		
		self.users = newFollowers;
		
		// clean up
		[jsonString release];
		
		// We've finished loading the artists
		usersLoaded = YES;
    }
	
	// Reload table
	[self.usersTable reloadData];
	
	[self hideLoading];
    
    [usersFetcher release];
    usersFetcher = nil;
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


- (void)saveSelections:(id)sender {

	NSArray *selectedPaths = [self.usersTable indexPathsForSelectedRows];
	NSMutableArray *selectedUsers = [NSMutableArray array];
	
	for (int i = 0; i < [selectedPaths count]; i++) {
		
		NSIndexPath *path = [selectedPaths objectAtIndex:i];
		
		NSDictionary *user = [self.users objectAtIndex:[path row]];
		NSString *username = [user objectForKey:@"username"];
		
		[selectedUsers addObject:username];
	}
	
	// Pass the usernames array to the delegate (Create Guide VC)
	[self.delegate recommendToUsernames:selectedUsers];
	
	// Go back to Create Guide VC
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initFindUserAPI {
	
	NSString *postString = [NSString stringWithFormat:@"q=%@", self.searchField.text];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindUser"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	usersFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedFindUserResponse:)];
	[usersFetcher start];
}


// Example fetcher response handling
- (void)receivedFindUserResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == usersFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	NSLog(@"PRINTING USER SEARCH DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// We've finished loading the cities
		usersLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.users = [results objectForKey:@"users"];
		
		NSLog(@"self.users:%@", self.users);
    }
	
	[self hideLoading];
	
	[self.usersTable reloadData];
    
    [usersFetcher release];
    usersFetcher = nil;
}



@end
