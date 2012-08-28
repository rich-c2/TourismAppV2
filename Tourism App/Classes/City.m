//
//  City.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "City.h"
#import "Guide.h"
#import "Photo.h"


@implementation City


+ (City *)cityWithTitle:(NSString *)cityTitle inManagedObjectContext:(NSManagedObjectContext *)context {
	
	City *city = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"title = %@", cityTitle];
	
	NSError *error = nil;
	city = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	// If no error and no City object was found
	if (!error && !city) {
		
		NSLog(@"ADDING City:%@", cityTitle);
		
		// Create a new City
		city = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
		city.title = cityTitle;
	}
	
	return city;
}

@dynamic cityID;
@dynamic title;
@dynamic locationForGuide;
@dynamic photosTakenHere;

@end
