//
//  MyCoreLocation.m
//  Telstra OSS Mobile Inventory
//
//  Created by Muliawan Sjarif on 20/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyCoreLocation.h"

@implementation MyCoreLocation

@synthesize locationManager, caller, updating;

- (id)init {
	
    self = [super init];
    if (self) {
		
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        self.locationManager.delegate = self;
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
		updating = NO;
		showErrors = NO;
    }
    
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
	
	if (newLocation.horizontalAccuracy <= 100) {
		
		updating = NO;
	
		[self.locationManager stopUpdatingLocation];
		
		NSLog(@"FOUND LOCATION");
		
		if ([(NSObject *)self.caller respondsToSelector:@selector(updateLocationDidFinish:)])
			[(NSObject *)self.caller performSelector:@selector(updateLocationDidFinish:) withObject:newLocation];
	}
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    
	if (showErrors) {
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Error" 
														message:[error description]
													   delegate:nil 
											  cancelButtonTitle:@"Close" 
											  otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
}


- (void)startUpdating {

	[self.locationManager startUpdatingLocation];
	
	updating = YES;
}


- (void)stopUpdating {
	
	updating = NO;
	
	[self.locationManager stopUpdatingLocation];
}


- (void)dealloc
{
    [locationManager release];
    [caller release];
    [super dealloc];
}

@end
