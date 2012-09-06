//
//  TAMapItVC.m
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAMapItVC.h"
#import "MyMapAnnotation.h"

@interface TAMapItVC ()

@end

@implementation TAMapItVC

@synthesize map, currentLocation, delegate, address;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// Add SAVE button to the top nav bar
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"SAVE" style:UIBarButtonItemStyleDone target:self action:@selector(saveLocation:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	[buttonItem release];
	
	[self initMapView];
}

- (void)viewDidUnload {
	
    [map release];
    self.map = nil;
	self.currentLocation = nil;
	
    [address release];
    self.address = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[currentLocation release];
    [map release];
    [address release];
    [super dealloc];
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
			[pinView setSelected:YES];
			[pinView setCanShowCallout:NO];
			[pinView setDraggable:YES];
		}
	}
	
	return pinView;
}


- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)annotationView 
didChangeDragState:(MKAnnotationViewDragState)newState 
   fromOldState:(MKAnnotationViewDragState)oldState  {
	
	if (oldState == MKAnnotationViewDragStateDragging) {
		
		CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dragging at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
	
    if (newState == MKAnnotationViewDragStateEnding) {
		
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
		
		CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
		
		self.currentLocation = newLocation;
		[newLocation release];
		
		// Update street address label
		[self updateAddress];
    }
}


- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	NSLog(@"didSelectAnnotationView");
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
	
	NSLog(@"DESELECT");
}


/*	The MKMapView has been 'created' in IB but this function formats 
 the region of the map, what it is centered around, zoom level etc. 
 It also calls the placeStore function. */
- (void)initMapView {
	
	// Map type
	self.map.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.0006;
	span.longitudeDelta = 0.0006;
	
	CLLocationCoordinate2D coordLocation;
	coordLocation.latitude = self.currentLocation.coordinate.latitude;
	coordLocation.longitude = self.currentLocation.coordinate.longitude;
	region.span = span;
	region.center = coordLocation;
	
	[self.map setRegion:region animated:TRUE];
	[self.map regionThatFits:region];
	
	NSString *title = @"Photo location";
	
	MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:self.currentLocation.coordinate title:title];
	[self.map addAnnotation:mapAnnotation];
	[mapAnnotation release];
	
	
	// Update street address label
	[self updateAddress];
}


- (void)saveLocation:(id)sender {

	// Pass the location that the user has selected
	// onto the delegate, and pop back to the share VC
	[self.delegate locationMapped:self.currentLocation];
	
	NSArray *viewControllers = [self.navigationController viewControllers];
	UIViewController *shareVC = [viewControllers objectAtIndex:([viewControllers count] - 3)];
	
	[self.navigationController popToViewController:shareVC animated:YES];
}


- (void)updateAddress {

	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
	 {
		 
		 if(placemarks && placemarks.count > 0) {
			 
			 NSLog(@"Received placemarks: %@", placemarks);
			 CLPlacemark *topResult = [placemarks objectAtIndex:0];
			 
			 // Update the label at the bottom of the mapContainer to display the latest fetched address
			 NSString *locationAddress = [NSString stringWithFormat:@"%@ %@, %@ %@ %@", [topResult subThoroughfare],[topResult thoroughfare],[topResult subLocality], [topResult administrativeArea], [topResult postalCode]];
			 
			 if ([locationAddress length] > 0) self.address.text = locationAddress;
		 }
	 }];
	
	[geocoder release];
}


@end
