//
//  TAPlacesVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAPlacesVC.h"
#import "StringHelper.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "TAMapItVC.h"
#import "SVProgressHUD.h"

NSString* const CLIENT_ID = @"DKN1SLXTCU0PUYUXXLNQDO1DYBNX2WZ3GJCXU0FMSZSYMQSK";
NSString* const CLIENT_SECRET = @"GIJHYETIFSBFBMWGRKXJ0TPYZJ0UGRP2B5WRGWD5E5TKFZKV";

@interface TAPlacesVC ()

@end

@implementation TAPlacesVC

@synthesize placesTable, mapItBtn, places, latitude, longitude, delegate;


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
    
	self.places = [NSMutableArray array];
}

- (void)viewDidUnload {
	
	self.places = nil;
	self.latitude = nil; 
	self.longitude = nil;
	
    [placesTable release];
    placesTable = nil;
    [mapItBtn release];
    mapItBtn = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[latitude release]; 
	[longitude release];
    [placesTable release];
    [mapItBtn release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	
	
	if (!loading && !venuesLoaded) {
		
		[self showLoading];
		
		loading = YES;
	
		// Start the location managing - tell it to start updating, 
		// if it's not already doing so
		[self searchVenues];
	
	}
		
    [super viewWillAppear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.places count];
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    // Retrieve the Dictionary at the given index that's in self.followers
	NSDictionary *place = [self.places objectAtIndex:[indexPath row]];
	
	NSString *placeName = [place objectForKey:@"name"];
	
	[cell.textLabel setText:placeName];
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
	
	// Retrieve the corresponding place dictionary
	// then extract the relevant data we need to pass to the delegate
	// and place it within a dictionary of it's own
	// Then 'pop' the user back one VC
	NSDictionary *place = [self.places objectAtIndex:[indexPath row]];
	
	NSMutableDictionary *placeData = [NSMutableDictionary dictionary];
	[placeData setObject:[place objectForKey:@"location"] forKey:@"location"];
	[placeData setObject:[place objectForKey:@"name"] forKey:@"name"];
	[placeData setObject:[place objectForKey:@"verified"] forKey:@"verified"];
	
	[self.delegate placeSelected:placeData];
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)mapItButtonTapped:(id)sender {
	
	CLLocation *location = [[[CLLocation alloc] initWithLatitude:[self.latitude doubleValue] longitude:[self.longitude doubleValue]] autorelease];

	TAMapItVC *mapItVC = [[TAMapItVC alloc] initWithNibName:@"TAMapItVC" bundle:nil];
	[mapItVC setCurrentLocation:location];
	[mapItVC setDelegate:self.delegate];
	
	[self.navigationController pushViewController:mapItVC animated:YES];
	[mapItVC release];
}


- (void)searchVenues {
	
	//[self.loadingSpinner startAnimating];
	
	NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&client_id=%@&client_secret=%@&v=20120703", [self.latitude doubleValue], [self.longitude doubleValue], CLIENT_ID, CLIENT_SECRET];
	
	NSURL *url = [urlString convertToURL];
    
    // Initialiase the URL Request
    NSMutableURLRequest *request =(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    // Add the Authorization header with the credentials made above. 
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
	
	// JSONFetcher
    venuesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedVenuesResponse:)];
    [venuesFetcher start];
}


// Example fetcher response handling
- (void)receivedVenuesResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == venuesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING VENUES DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	//[self.loadingSpinner stopAnimating];
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		venuesLoaded = YES;
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		[jsonString release];
		
		// Build an array from the dictionary for easy access to each entry
		NSDictionary *responseDict = [results objectForKey:@"response"];
		
		NSMutableArray *newVenues = (NSMutableArray *)[responseDict objectForKey:@"venues"];
		
		self.places = newVenues;
		
		NSLog(@"venues:%@", self.places);
    }
	
	[self hideLoading];
	
	// Reload table
	[self.placesTable reloadData];
    
    [venuesFetcher release];
    venuesFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


@end
