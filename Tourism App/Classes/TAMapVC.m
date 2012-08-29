//
//  TAMapVC.m
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMapVC.h"
#import "MyMapAnnotation.h"

@interface TAMapVC ()

@end

@implementation TAMapVC

@synthesize map, mapMode, locationData;


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

- (void)viewDidUnload {
	
	self.locationData = nil; 
	
    [map release];
    self.map = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[locationData release];
    [map release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	if (self.mapMode == MapModeSingle) 
		[self initSingleLocation];
}


#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;		
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	MKPinAnnotationView* pinView;
	
    if ([annotation isKindOfClass:[MyMapAnnotation class]]) {
		
		// try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        pinView = (MKPinAnnotationView *)
		[self.map dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!pinView) {
			
			pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier] autorelease];
			
			[pinView setUserInteractionEnabled:YES];
			[pinView setCanShowCallout:NO];
		}
	}
	
	return pinView;
}


#pragma MY-METHODS 

- (void)initSingleLocation {

	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = [[self.locationData objectForKey:@"latitude"] doubleValue];
	coordLocation.longitude = [[self.locationData objectForKey:@"longitude"] doubleValue];
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Test pin";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
	[self.map addAnnotation:mapAnnotation];
	[mapAnnotation release];
}



@end
