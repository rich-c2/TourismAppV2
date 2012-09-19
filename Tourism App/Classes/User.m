//
//  User.m
//  Tourism App
//
//  Created by Richard Lee on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Guide.h"
#import "Photo.h"
#import "TAAppDelegate.h"


@implementation User


// Here the persistant store will be queried using the username data within the basicInfo dictionary.
// The basicInfo dictionary will only contain a username and avatarURL.
+ (User *)userWithBasicData:(NSDictionary *)basicInfo inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"username = %@", [basicInfo objectForKey:@"username"]];
	
	NSError *error = nil;
	user = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !user) {
		
		// Create a new User
		user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
		user.username = [basicInfo objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [basicInfo objectForKey:@"avatar"]];
		user.fullName = [basicInfo objectForKey:@"name"];
	}
	
	else if (!error && user) {
		
		// Update user properties
		user.username = [basicInfo objectForKey:@"username"];
		user.avatarURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [basicInfo objectForKey:@"avatar"]];
		user.fullName = [basicInfo objectForKey:@"name"];
	}
	
	return user;
}


// Here the persistant store will be queried using just a username 
+ (User *)userWithUsername:(NSString *)theUsername 
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"username = %@", theUsername];
	
	NSError *error = nil;
	user = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	return user;
}


@dynamic avatarThumbURL;
@dynamic avatarURL;
@dynamic city;
@dynamic emailAddress;
@dynamic firstName;
@dynamic followersCount;
@dynamic followingCount;
@dynamic guidesCount;
@dynamic lastName;
@dynamic photosCount;
@dynamic username;
@dynamic fullName;
@dynamic comments;
@dynamic followingGuides;
@dynamic guides;
@dynamic photosTaken;

@end
