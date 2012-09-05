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

@interface TAExploreVC ()

@end

@implementation TAExploreVC

@synthesize tagBtn, selectedTag, selectedCity, cityBtn, locationManager, currentLocation;
@synthesize nearbyBtn;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       
		self.title = @"Explore";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	// Get user location
	MyCoreLocation *location = [[MyCoreLocation alloc] init];
	self.locationManager = location;
	[location release];
	
	// We are the delegate for the MyCoreLocation object
	[self.locationManager setCaller:self];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.locationManager = nil;
	self.currentLocation = nil;
	
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
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
	
	// Stop the loading animation
	//[self.loadingSpinner stopAnimating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
	
}


#pragma LocationsDelegate

- (void)locationSelected:(NSDictionary *)city {
	
	useCurrentLocation = NO;
	
	// Set the selected City
	[self setSelectedCity:city]; 
	
	// Set the city button's title to that of the City selected
	[self.cityBtn setTitle:[city objectForKey:@"city"] forState:UIControlStateNormal];
}


#pragma TagsDelegate

- (void)tagSelected:(Tag *)tag {
	
	// Set the selected Tag
	[self setSelectedTag:tag]; 
	
	// Set the Tag button's title to that of the Location's
	[self.tagBtn setTitle:tag.title forState:UIControlStateNormal];
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

	TAMediaResultsVC *mediaResultsVC = [[TAMediaResultsVC alloc] initWithNibName:@"TAMediaResultsVC" bundle:nil];
	[mediaResultsVC setCity:[self.selectedCity objectForKey:@"city"]];
	[mediaResultsVC setTag:self.selectedTag.title];
	[mediaResultsVC setTagID:self.selectedTag.tagID];
	
	
	// NEARBY FUNCTIONALITY NOT IMPLEMENTED
	

	[self.navigationController pushViewController:mediaResultsVC animated:YES];
	[mediaResultsVC release];
}


- (IBAction)nearbyButtonTapped:(id)sender {

	useCurrentLocation = YES;
}


@end
