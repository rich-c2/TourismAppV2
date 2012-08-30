//
//  TAMediaResultsVC.m
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMediaResultsVC.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "TAAppDelegate.h"
#import "TAGuidesListVC.h"
#import "TAImageGridVC.h"

@interface TAMediaResultsVC ()

@end

@implementation TAMediaResultsVC

@synthesize tag, city, tagID, images;
@synthesize cityLabel, tagLabel, guides;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
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
	
	self.tagID = nil;
	self.tag = nil;
	self.city = nil;
	self.guides = nil;
	self.images = nil;
	
	[cityLabel release];
	self.cityLabel = nil;
	[tagLabel release];
	self.tagLabel = nil;
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {

	[images release];
	[guides release];
	[tagID release];
	[tag release]; 
	[city release];
	[cityLabel release];
	[tagLabel release];
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	[self.cityLabel setText:self.city];
	[self.tagLabel setText:self.tag];
	
	[self showLoading];
	
	[self initFindMediaAPI];
	
	[self initFindGuidesAPI];
}


#pragma MY METHODS

- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initFindMediaAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%@&token=%@", [self appDelegate].loggedInUsername, [self.tagID intValue], self.city, 0, @"20", [[self appDelegate] sessionToken]];
	NSLog(@"jsonString:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindMedia"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	mediaFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedFindMediaResponse:)];
	[mediaFetcher start];
}


// Example fetcher response handling
- (void)receivedFindMediaResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == mediaFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.images = [results objectForKey:@"media"];
		
		[jsonString release];
    }
    
    [mediaFetcher release];
    mediaFetcher = nil;
}


- (void)initFindGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%@&private=0&token=%@", [self appDelegate].loggedInUsername, [self.tagID intValue], self.city, 0, @"20", [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindGuides"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	guidesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindGuidesResponse:)];
	[guidesFetcher start];
	
	[self hideLoading];
}	


// Example fetcher response handling
- (void)receivedFindGuidesResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING GET GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
		
		[jsonString release];
    }
    
    [guidesFetcher release];
    guidesFetcher = nil;
}


- (IBAction)guidesButtonTapped:(id)sender {
	
	NSMutableArray *guidesCopy = [self.guides mutableCopy];
	
	TAGuidesListVC *guidesListVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesListVC setGuidesMode:GuidesModeSearchResults];
	[guidesListVC setGuides:guidesCopy];
	[guidesCopy release];
	
	[self.navigationController pushViewController:guidesListVC animated:YES];
	[guidesListVC release];
}


- (IBAction)photosButtonTapped:(id)sender {
	
	//NSMutableArray *imagesCopy = [self.images mutableCopy];
	
	NSLog(@"HERE ARE THE IMAGES:%@", self.images);
	
	TAImageGridVC *gridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[gridVC setImagesMode:ImagesModeCityTag];
	[gridVC setImages:self.images];
	
	[self.navigationController pushViewController:gridVC animated:YES];
	[gridVC release];
}



@end
