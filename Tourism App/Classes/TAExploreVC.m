//
//  TAExploreVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAExploreVC.h"
#import "TASimpleListVC.h"
#import "TAAppDelegate.h"
#import "TACitiesListVC.h"
#import "TAMediaResultsVC.h"
#import "MyCoreLocation.h"
#import "Photo.h"
#import "XMLFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "CustomTabBarItem.h"

@interface TAExploreVC ()

@end

@implementation TAExploreVC

@synthesize tagBtn, selectedTag, selectedCity, cityBtn, locationManager, currentLocation;
@synthesize nearbyBtn, exploreMode, images, photos, delegate;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		/*
		CustomTabBarItem *tabItem = [[CustomTabBarItem alloc] initWithTitle:@"" image:nil tag:0];
        
        tabItem.customHighlightedImage = [UIImage imageNamed:@"feed_tab_button-on.png"];
        tabItem.customStdImage = [UIImage imageNamed:@"feed_tab_button.png"];
        self.tabBarItem = tabItem;
        [tabItem release];
        tabItem = nil;
       */
		self.title = @"Explore";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Setup nav bar
	[self initNavBar];
	
	if (self.exploreMode == ExploreModeSubset) {
	
		// Hide the nearby btn
		self.nearbyBtn.hidden = YES;
		
		//[self serializeImages];
	}
    
	else {
		
		// Get user location
		MyCoreLocation *location = [[MyCoreLocation alloc] init];
		self.locationManager = location;
		[location release];
		
		// We are the delegate for the MyCoreLocation object
		[self.locationManager setCaller:self];
	}
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.locationManager = nil;
	self.currentLocation = nil;
	self.images = nil;
	self.photos = nil;
	
	self.selectedTag = nil;
	self.selectedCity = nil;
	
	[tagBtn release];
	tagBtn = nil;
	[cityBtn release];
	self.cityBtn = nil;
	
	[nearbyBtn release];
	self.nearbyBtn = nil;
	
    [super viewDidUnload];
}


- (void)viewWillAppear:(BOOL)animated {

	if (self.exploreMode != ExploreModeSubset && !self.locationManager.updating) [self.locationManager startUpdating];
	
	
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[photos release];
	[images release];
	[currentLocation release];
	[locationManager release];
	[selectedCity release];
	[selectedTag release];
	[tagBtn release];
	[cityBtn release];
	[nearbyBtn release];
	[super dealloc];
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    if (currentLocation) [currentLocation release];
    currentLocation = [loc retain];
	
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
}


#pragma LocationsDelegate

- (void)locationSelected:(NSDictionary *)city {
	
	useCurrentLocation = NO;
	
	// Set the selected City
	[self setSelectedCity:[city objectForKey:@"city"]]; 
	
	// Set the city button's title to that of the City selected
	[self.cityBtn setTitle:self.selectedCity forState:UIControlStateNormal];
}


#pragma TagsDelegate

- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag]; 
	
	// Set the Tag button's title to that of the Location's
	[self.tagBtn setTitle:tag.title forState:UIControlStateNormal];
}



- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (IBAction)goBack:(id)sender {
	
	[self.navigationController popViewControllerAnimated:YES];
}


- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (IBAction)selectTagButtonTapped:(id)sender {

	TASimpleListVC *tagListVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[tagListVC setListMode:ListModeTags];
	[tagListVC setManagedObjectContext:[self appDelegate].managedObjectContext];
	[tagListVC setDelegate:self];
	
	[self.navigationController pushViewController:tagListVC animated:YES];
	[tagListVC release];
}


- (IBAction)selectCityButtonTapped:(id)sender {
	
	TACitiesListVC *citiesListVC = [[TACitiesListVC alloc] initWithNibName:@"TACitiesListVC" bundle:nil];
	[citiesListVC setDelegate:self];
	
	[self.navigationController pushViewController:citiesListVC animated:YES];
	[citiesListVC release];
}


- (IBAction)exploreButtonTapped:(id)sender {
	
	if (self.exploreMode == ExploreModeSubset) {
	
		NSArray *results = [self.photos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"city.title = %@ AND tag.tagID = %@", self.selectedCity, self.selectedTag.tagID]];
		
		[self.delegate finishedFilteringWithPhotos:results];
		
		[self.navigationController popViewControllerAnimated:YES];
	}
	
	else {
		
		TAMediaResultsVC *mediaResultsVC = [[TAMediaResultsVC alloc] initWithNibName:@"TAMediaResultsVC" bundle:nil];
		[mediaResultsVC setCity:self.selectedCity];
		[mediaResultsVC setTag:self.selectedTag.title];
		[mediaResultsVC setTagID:self.selectedTag.tagID];
		
		
		// NEARBY FUNCTIONALITY NOT IMPLEMENTED
		
		
		[self.navigationController pushViewController:mediaResultsVC animated:YES];
		[mediaResultsVC release];
	}
}


- (IBAction)nearbyButtonTapped:(id)sender {

	//useCurrentLocation = YES;
	
	if (!self.locationManager.updating) {
		
		[self showLoading];
		
		[self retrieveLocationData];

	}
	
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Still updating your location!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[av show];
		[av release];
	}
}


/*
	Iterates through the self.images array,  
	converts all the Dictionary values to
	Photos (NSManagedObjects) and stores
	them in self.photos array
*/
- (void)serializeImages {
	
	self.photos = [NSMutableArray array];
	
	NSManagedObjectContext *context = [self appDelegate].managedObjectContext;

	for (NSDictionary *image in self.images) {
	
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:context];
		[self.photos addObject:photo];
	}
}


- (void)retrieveLocationData {
	
	// Create JSON call to retrieve dummy City values
	NSString *methodName = @"geocode";
	NSString *yahooURL = @"http://where.yahooapis.com/";
	NSString *yahooAPIKey = @"UvRWaq30";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@?q=%f,%f&gflags=R&appid=%@", yahooURL, methodName, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, yahooAPIKey];
	NSLog(@"YAHOO URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(HTTPFetcher *)aFetcher {
    
    XMLFetcher *theXMLFetcher = (XMLFetcher *)aFetcher;
    NSAssert(aFetcher == cityFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	// IF STATUS CODE WAS OKAY (200)
	if ([theXMLFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([theXMLFetcher.data length] > 0) && ([theXMLFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [theXMLFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) { 
							
							NSLog(@"SELECTED LOCATION:%@", [childNode contentString]);
							
							self.selectedCity = [childNode contentString];
						}
					}
				}
			}
		}
	}
	
	if (requestSuccess && !errorDected) {
		
		[self.cityBtn setTitle:self.selectedCity forState:UIControlStateNormal];
	}
	else [self.cityBtn setTitle:@"Could not assign city." forState:UIControlStateNormal];
	
	[self hideLoading];
    
    [cityFetcher release];
    cityFetcher = nil;	
	
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}

@end
