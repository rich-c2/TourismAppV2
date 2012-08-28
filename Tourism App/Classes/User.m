//
//  User.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "User.h"
#import "Guide.h"


@implementation User


// Here the persistant store will be queried using just a username 
+ (User *)userWithUsername:(NSString *)theUsername 
	inManagedObjectContext:(NSManagedObjectContext *)context {
	
	User *user = nil;
	
	NSLog(@"Fetching username:%@", theUsername);
	
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
@dynamic comments;
@dynamic followingGuides;
@dynamic guides;

@end
