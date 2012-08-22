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

@interface TANotificationsVC ()

@end

@implementation TANotificationsVC

@synthesize reccomendations, recommendationsTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
	
	[recommendationsTable release];
	self.recommendationsTable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	self.reccomendations = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {

	[reccomendations release];
	
	[recommendationsTable release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (!loading && !recommendationsLoaded) { 
		
		[self showLoading];
		
		[self initRecommendationsAPI];
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
	
    return [self.reccomendations count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.users
	NSDictionary *rec = [self.reccomendations objectAtIndex:[indexPath row]];
	
	NSString *title = [rec objectForKey:@"title"];
	NSString *subtitle = [rec objectForKey:@"subtitle"];
	
	[cell.textLabel setText:title];
	[cell.detailTextLabel setText:subtitle];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the Dictionary at the given index that's in self.users
	/*NSDictionary *user = [self.users objectAtIndex:[indexPath row]];
	 
	 TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	 [profileVC setUsername:[user objectForKey:@"username"]];
	 //[profileVC setManagedObjectContext:self.managedObjectContext];
	 
	 [self.navigationController pushViewController:profileVC animated:YES];
	 [profileVC release];*/
}


- (void)initRecommendationsAPI {
	
	NSString *type = @"recommendations";
	
	NSInteger page = 0;
	NSInteger size = 10;
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@&category=%@&pg=%i&sz=%i", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken], type, page, size];
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
	
	[self.recommendationsTable reloadData];
	
	[self hideLoading];
	
	[recommendationsFetcher release];
	recommendationsFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}

@end
