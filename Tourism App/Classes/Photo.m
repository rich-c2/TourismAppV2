//
//  Photo.m
//  Tourism App
//
//  Created by Richard Lee on 7/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "City.h"
#import "Guide.h"
#import "Tag.h"
#import "TAAppDelegate.h"


@implementation Photo


+ (Photo *)photoWithPhotoData:(NSDictionary *)photoData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Photo *photo = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"photoID = %@", [photoData objectForKey:@"code"]];
	
	NSError *error = nil;
	photo = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !photo) {
		
		NSLog(@"ADDING IMAGE:%@", [photoData objectForKey:@"code"]);
		
		// Create a new Image
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"]; 
		
		// Convert string to date object		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		[dateFormatter release];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount  = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
		
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context]; 
		
		// TAG			
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		
		// LOCATION
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
	}
	
	else if (!error && photo) {
		
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"]; 
		
		// Convert string to date object		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		[dateFormatter release];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount  = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
		
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context]; 
		
		// TAG			
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		// LOCATION
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
	}
	
	return photo;
}


@dynamic caption;
@dynamic date;
@dynamic lovesCount;
@dynamic photoID;
@dynamic thumbURL;
@dynamic url;
@dynamic vouchesCount;
@dynamic latitude;
@dynamic longitude;
@dynamic username;
@dynamic city;
@dynamic comments;
@dynamic inGuides;
@dynamic tag;
@dynamic venue;

@end
