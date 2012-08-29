//
//  Tag.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Tag.h"
#import "Guide.h"
#import "Photo.h"


@implementation Tag


+ (Tag *)tagWithID:(NSInteger)tagIDNum inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Tag *tag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"tagID == %i", tagIDNum];
	
	NSError *error = nil;
	tag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (tag) NSLog(@"Found tag:%@", tag.title);
	
	return tag;
}


+ (Tag *)tagWithTitle:(NSString *)tagTitle andID:(NSInteger)tagIDNum
inManagedObjectContext:(NSManagedObjectContext *)context {
	
	Tag *tag = nil;
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	request.entity = [NSEntityDescription entityForName:@"Tag" inManagedObjectContext:context];
	request.predicate = [NSPredicate predicateWithFormat:@"tagID == %i", tagIDNum];
	
	NSError *error = nil;
	tag = [[context executeFetchRequest:request error:&error] lastObject];
	[request release];
	
	if (!error && !tag) {
		
		NSLog(@"Tag CREATED:%@", tagTitle);
		
		// Create a new tag
		tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
		tag.title = tagTitle;
		tag.tagID = [NSNumber numberWithInt:tagIDNum];
	}
	
	return tag;
}


@dynamic tagID;
@dynamic title;
@dynamic forGuides;
@dynamic onPhoto;

@end
