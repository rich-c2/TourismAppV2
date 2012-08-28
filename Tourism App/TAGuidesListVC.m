//
//  TAGuidesListVC.m
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAGuidesListVC.h"
#import "TAAppDelegate.h"
#import "StringHelper.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "TAGuideDetailsVC.h"
#import "Guide.h"
#import "City.h"
#import "Tag.h"

@interface TAGuidesListVC ()

@end

@implementation TAGuidesListVC

@synthesize guidesMode, guidesTable, guides, username;
@synthesize selectedTag, selectedCity;

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
    // Do any additional setup after loading the view from its nib.
	
	self.guides = [NSMutableArray array];
}

- (void)viewDidUnload {
	
	self.username = nil;
	self.guides = nil;
	self.selectedTag = nil; 
	self.selectedCity = nil;
	
    [guidesTable release];
    guidesTable = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (!loading && !guidesLoaded) { 
		
		[self showLoading];
	
		if (self.guidesMode == GuidesModeFollowing) [self initFollowedGuidesAPI];
		
		else [self initMyGuidesAPI];
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
	
    return [self.guides count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
	NSString *guideTitle;
	NSString *subtitle;
	
	if (self.guidesMode == GuidesModeAddTo) {
		
		Guide *guide = [self.guides objectAtIndex:[indexPath row]];
		
		guideTitle = [guide title];
		subtitle = [NSString stringWithFormat:@"City:%@/Tag:%@", [guide.city title], [guide.tag title]];
	}
	
	else {
		
		// Retrieve the Dictionary at the given index that's in self.users
		NSDictionary *guide = [self.guides objectAtIndex:[indexPath row]];
		
		guideTitle = [guide objectForKey:@"title"];
		subtitle = [NSString stringWithFormat:@"City:%@/Tag:%@", [guide objectForKey:@"city"], [guide objectForKey:@"tag"]];
	}
	
	[cell.textLabel setText:guideTitle];
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
	NSDictionary *guide = [self.guides objectAtIndex:[indexPath row]];
	
	TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
	[guideDetailsVC setGuideID:[guide objectForKey:@"guideID"]];
	
	// Is this a guide that the logged-in user created or someone else's?
	[guideDetailsVC setGuideMode:GuideModeCreated];
	
	[self.navigationController pushViewController:guideDetailsVC animated:YES];
	[guideDetailsVC release];
}


- (void)initMyGuidesAPI {

	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@", self.username, [[self appDelegate] sessionToken]];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"MyGuides"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	guidesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedMyGuidesResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedMyGuidesResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING MY GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		
		// For 'Add To' mode we need to
		// serialize the Guides data so that
		// we can filter out the Guides that don't
		// match the city/tag combo we're looking for
		if (self.guidesMode == GuidesModeAddTo) {

			NSArray *tempGuides = [[self appDelegate] serializeGuideData:self.guides];
			
			self.guides = (NSMutableArray *)[tempGuides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"city.title = %@ AND tag.title = %@", self.selectedCity, self.selectedTag]];
		}
		
		else {
			
			// Build an array from the dictionary for easy access to each entry
			self.guides = [results objectForKey:@"guides"];
		}
		
		[jsonString release];
	}
	
	[self finishedMyGuidesRequest];
	
	[guidesFetcher release];
	guidesFetcher = nil;
}


- (void)finishedMyGuidesRequest {
	
	[self.guidesTable reloadData];
	
	[self hideLoading];
}


- (void)initFollowedGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&token=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken]];
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"GetFollowedGuides"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	guidesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedFollowedGuideResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowedGuideResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING GET GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	loading = NO;
	
    if ([theJSONFetcher.data length] > 0) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
    }
	
	// Reload the table
	[self.guidesTable reloadData];
	
	[self hideLoading];
    
    [guidesFetcher release];
    guidesFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)dealloc {
	
	[selectedTag release];
	[selectedCity release];
	[username release];
	[guides release];
    [guidesTable release];
    [super dealloc];
}

@end
