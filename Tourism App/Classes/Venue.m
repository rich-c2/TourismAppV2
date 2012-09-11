//
//  Venue.m
//  Tourism App
//
//  Created by Richard Lee on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Venue.h"
#import "Photo.h"


@implementation Venue

+ (Venue *)venueWithData:(NSDictionary *)venueData location:(NSDictionary *)locationData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Venue *venue = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Venue" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", [venueData objectForKey:@"title"]];
	
	NSError *error = nil;
	venue = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !venue) {
		
		// Create a new User
		venue = [NSEntityDescription insertNewObjectForEntityForName:@"Venue" inManagedObjectContext:context];
		venue.title = [venueData objectForKey:@"title"];
		venue.address = [venueData objectForKey:@"address"];
		venue.city = [venueData objectForKey:@"city"];
		venue.state = [venueData objectForKey:@"state"];
		venue.country = [venueData objectForKey:@"country"];
		venue.postcode = [venueData objectForKey:@"postcode"];
		
		venue.latitude = [NSNumber numberWithDouble:[[venueData objectForKey:@"latitude"] doubleValue]];
		venue.longitude = [NSNumber numberWithDouble:[[venueData objectForKey:@"longitude"] doubleValue]];
	}
	
	return venue;
}


@dynamic address;
@dynamic latitude;
@dynamic longitude;
@dynamic title;
@dynamic venueID;
@dynamic city;
@dynamic state;
@dynamic country;
@dynamic postcode;
@dynamic photosTakenHere;

@end
