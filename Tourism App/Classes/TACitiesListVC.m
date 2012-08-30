//
//  TACitiesListVC.m
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACitiesListVC.h"
#import "SVProgressHUD.h"
#import "TAAppDelegate.h"
#import "SBJson.h"
#import "JSONFetcher.h"

@interface TACitiesListVC ()

@end

@implementation TACitiesListVC

@synthesize cities, citiesTable, delegate, searchField;

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


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
    [citiesTable release];
    self.citiesTable = nil;
	
	self.cities = nil; 
	self.citiesTable = nil; 
	
	[searchField release];
	self.searchField = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[cities release]; 
    [citiesTable release];
	[searchField release];
    [super dealloc];
}


#pragma mark Search Bar Delegate methods
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	
	[self initCitySearchAPI];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger numberOfRows = [self.cities count];
    
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"Cell";
	
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (cell == nil) {
		
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	[self configureCell:cell atIndexPath:indexPath tableView:tableView];
	
    return cell;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
	
	// Retrieve City from cities array
	NSDictionary *city = [self.cities objectAtIndex:[indexPath row]];
	NSString *cellTitle = [city objectForKey:@"city"]; 
	
	// Set the text of the cell
	cell.textLabel.text = cellTitle;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Need to pass the location that was selected to the Delegate
	// of this view controller
	NSDictionary *city = [self.cities objectAtIndex:[indexPath row]];
		
	// Pass the selected city to our delegate
	[self.delegate locationSelected:city];
		
	// Go back to the previous screen
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)initCitySearchAPI {
	
	NSString *postString = [NSString stringWithFormat:@"q=%@", self.searchField.text];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"citysearch"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	citiesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													 receiver:self action:@selector(receivedCitySearchResponse:)];
	[citiesFetcher start];
}


// Example fetcher response handling
- (void)receivedCitySearchResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == citiesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	loading = NO;
	
	//NSLog(@"PRINTING CITY SEARCH DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// We've finished loading the cities
		citiesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.cities = [results objectForKey:@"cities"];
		
		NSLog(@"self.cities:%@", self.cities);
    }
	
	[self hideLoading];
	
	[self.citiesTable reloadData];
    
    [citiesFetcher release];
    citiesFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


@end
