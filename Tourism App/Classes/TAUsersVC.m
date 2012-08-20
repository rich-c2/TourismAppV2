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

@interface TAUsersVC ()

@end

@implementation TAUsersVC

@synthesize usersMode;
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
    
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
    [super viewDidUnload];
    
	self.usersTable	= nil;
	self.selectedUsername = nil;
	self.users = nil;
	self.managedObjectContext = nil;

}

- (void)dealloc {
	
	[usersTable release];
	[selectedUsername release];
	[users release];
	[managedObjectContext release];
	
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
		
		if (self.usersMode == UsersModeFollowing) [self initFollowingAPI];
		
		//else if (self.usersMode == UsersModeFollowers) [self initFollowersAPI];
		
		//else if (self.usersMode == UsersModeRecommendTo) [self initFollowersAPI];
		
		/*else if (self.usersMode == UsersModeFindViaContacts) [self initFollowersAPI];
		
		else if (self.usersMode == UsersModeFindViaFB) [self initFollowersAPI];
		
		else if (self.usersMode == UsersModeFindViaTwitter) [self initFollowersAPI];*/
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.users count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
	
	[cell.textLabel setText:[user objectForKey:@"username"]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
		
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:[user objectForKey:@"username"]];
	//[profileVC setManagedObjectContext:self.managedObjectContext];
	
	[self.navigationController pushViewController:profileVC animated:YES];
	[profileVC release];
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
	
	// We've finished loading the artists
	usersLoaded = YES;
	
	NSLog(@"PRINTING FOLLOWING:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0) {
        
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
		
		NSLog(@"followers:%@", self.users);
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

@end
