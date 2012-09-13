//
//  Photo.m
//  Tourism App
//
//  Created by Richard Lee on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Photo.h"
#import "City.h"
#import "Guide.h"
#import "Tag.h"
#import "User.h"
#import "Venue.h"
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
		
		NSLog(@"ADDING PHOTO:%@", [photoData objectForKey:@"code"]);
		
		// Create a new Photo
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"]; 
		
		// Convert string to date object		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		[dateFormatter release];
		
		// TIME ELAPSED
		photo.timeElapsed = [photoData objectForKey:@"elapsed"];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		photo.whoTook = [User userWithBasicData:userDict inManagedObjectContext:context];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
		
		// VOUCHES COUNT
		photo.vouchesCount = [NSNumber numberWithInt:[[countData objectForKey:@"vouches"] intValue]];
		
		// isLOVED
		BOOL isLovedBool = (([[photoData objectForKey:@"isLoved"] isEqualToString:@"true"]) ? YES : NO);
		photo.isLoved = [NSNumber numberWithBool:isLovedBool];
		
		// isVOUCHED
		BOOL isVouchedBool = (([[photoData objectForKey:@"isVouched"] isEqualToString:@"true"]) ? YES : NO);
		photo.isVouched = [NSNumber numberWithBool:isVouchedBool];
		
		// VERIFIED
		BOOL isVerified = (([[photoData objectForKey:@"verified"] isEqualToString:@"1"]) ? YES : NO);
		photo.verified = [NSNumber numberWithBool:isVerified];
		
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context]; 
		
		// TAG			
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		/* 
		 VENUE & LOCATION
		 */
		
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		NSDictionary *venueData = [photoData objectForKey:@"address"];
		photo.venue = [Venue venueWithData:venueData location:locationData inManagedObjectContext:context];
		
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
		
		////////////////////////////////////////////////////////////
	}
	
	else if (!error && photo) {
		
		// Create a new Photo
		photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.photoID = [photoData objectForKey:@"code"];
		photo.caption = [photoData objectForKey:@"caption"]; 
		
		// Convert string to date object		
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd/MM/yyyy hh:mm:ss a"];
		NSString *dateString = [photoData objectForKey:@"date"];
		NSDate *photoDate = [dateFormatter dateFromString:dateString];
		photo.date = photoDate;
		[dateFormatter release];
		
		// TIME ELAPSED
		photo.timeElapsed = [photoData objectForKey:@"elapsed"];
		
		// PATHS
		NSDictionary *imagePaths = [photoData objectForKey:@"paths"];
		photo.thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"thumb"]];
		photo.url = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [imagePaths objectForKey:@"zoom"]];
		
		// USER
		NSDictionary *userDict = [photoData objectForKey:@"user"];
		photo.username = [userDict objectForKey:@"username"];
		photo.whoTook = [User userWithBasicData:userDict inManagedObjectContext:context];
		
		// COUNT DATA
		NSDictionary *countData = [photoData objectForKey:@"count"];
		photo.lovesCount  = [NSNumber numberWithInt:[[countData objectForKey:@"loves"] intValue]];
		
		// VOUCHES COUNT
		photo.vouchesCount = [NSNumber numberWithInt:[[countData objectForKey:@"vouches"] intValue]];
		
		// isLOVED
		BOOL isLovedBool = (([[photoData objectForKey:@"isLoved"] isEqualToString:@"true"]) ? YES : NO);
		photo.isLoved = [NSNumber numberWithBool:isLovedBool];
		
		// isVOUCHED
		BOOL isVouchedBool = (([[photoData objectForKey:@"isVouched"] isEqualToString:@"true"]) ? YES : NO);
		photo.isVouched = [NSNumber numberWithBool:isVouchedBool];
		
		// VERIFIED
		BOOL isVerified = (([[photoData objectForKey:@"verified"] isEqualToString:@"1"]) ? YES : NO);
		photo.verified = [NSNumber numberWithBool:isVerified];
		
		//CITY
		photo.city = [City cityWithTitle:[photoData objectForKey:@"city"] inManagedObjectContext:context]; 
		
		// TAG			
		photo.tag = [Tag tagWithID:[[photoData objectForKey:@"tag"] intValue] inManagedObjectContext:context];
		
		
		/* 
			VENUE & LOCATION
		*/
		
		NSDictionary *locationData = [photoData objectForKey:@"location"];
		NSDictionary *venueData = [photoData objectForKey:@"address"];
		photo.venue = [Venue venueWithData:venueData location:locationData inManagedObjectContext:context];
		
		photo.latitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"latitude"] doubleValue]];
		photo.longitude = [NSNumber numberWithDouble:[[locationData objectForKey:@"longitude"] doubleValue]];
		
		////////////////////////////////////////////////////////////
	}
	
	return photo;
}


@dynamic caption;
@dynamic date;
@dynamic isLoved;
@dynamic isVouched;
@dynamic latitude;
@dynamic longitude;
@dynamic lovesCount;
@dynamic photoID;
@dynamic thumbURL;
@dynamic timeElapsed;
@dynamic url;
@dynamic username;
@dynamic verified;
@dynamic vouchesCount;
@dynamic city;
@dynamic comments;
@dynamic inGuides;
@dynamic tag;
@dynamic venue;
@dynamic whoTook;

@end
