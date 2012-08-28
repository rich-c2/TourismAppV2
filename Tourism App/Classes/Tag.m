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


@dynamic tagID;
@dynamic title;
@dynamic forGuides;
@dynamic onPhoto;

@end
