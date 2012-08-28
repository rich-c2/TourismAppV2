//
//  Guide.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Guide.h"
#import "City.h"
#import "Tag.h"
#import "User.h"

@implementation Guide


+ (Guide *)guideWithGuideData:(NSDictionary *)guideData inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Guide *guide = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Guide" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"guideID = %@", [guideData objectForKey:@"guideID"]];
	
	NSError *error = nil;
	guide = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	// If no error and no Guide object was found
	if (!error && !guide) {
		
		NSLog(@"ADDING GUIDE:%@", [guideData objectForKey:@"guideID"]);
		
		// CREATE A NEW GUIDE
		guide = [NSEntityDescription insertNewObjectForEntityForName:@"Guide" inManagedObjectContext:context];
		guide.guideID = [guideData objectForKey:@"guideID"];
		guide.title = [guideData objectForKey:@"title"];
		guide.private = [NSNumber numberWithInt:[[guideData objectForKey:@"private"] intValue]];
		
		// AUTHOR
		NSDictionary *userData = [guideData objectForKey:@"author"];
		[guide setAuthor:[User userWithUsername:[userData objectForKey:@"username"]  inManagedObjectContext:context]];
		
		// TAG
		[guide setTag:[Tag tagWithID:[[guideData objectForKey:@"tag"] intValue] inManagedObjectContext:context]];
		
		// CITY
		[guide setCity:[City cityWithTitle:[guideData objectForKey:@"city"] inManagedObjectContext:context]];
		
		// IMAGE IDs
		NSArray *imageArray = [guideData objectForKey:@"images"];
		NSString *idString = [imageArray componentsJoinedByString:@","];
		[guide setImageIDs:idString];
	}
	
	return guide;
}


@dynamic frontEndURL;
@dynamic guideID;
@dynamic imageIDs;
@dynamic private;
@dynamic title;
@dynamic author;
@dynamic city;
@dynamic followedBy;
@dynamic photos;
@dynamic tag;

@end
