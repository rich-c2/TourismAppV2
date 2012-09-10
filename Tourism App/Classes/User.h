//
//  User.h
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * avatarThumbURL;
@property (nonatomic, retain) NSString * avatarURL;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * followersCount;
@property (nonatomic, retain) NSNumber * followingCount;
@property (nonatomic, retain) NSNumber * guidesCount;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * photosCount;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *followingGuides;
@property (nonatomic, retain) NSSet *guides;
@property (nonatomic, retain) NSSet *photosTaken;
@end

@interface User (CoreDataGeneratedAccessors)

+ (User *)userWithBasicData:(NSDictionary *)basicInfo inManagedObjectContext:(NSManagedObjectContext *)context;
+ (User *)userWithUsername:(NSString *)theUsername 
	inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addFollowingGuidesObject:(Guide *)value;
- (void)removeFollowingGuidesObject:(Guide *)value;
- (void)addFollowingGuides:(NSSet *)values;
- (void)removeFollowingGuides:(NSSet *)values;

- (void)addGuidesObject:(Guide *)value;
- (void)removeGuidesObject:(Guide *)value;
- (void)addGuides:(NSSet *)values;
- (void)removeGuides:(NSSet *)values;

- (void)addPhotosTakenObject:(Photo *)value;
- (void)removePhotosTakenObject:(Photo *)value;
- (void)addPhotosTaken:(NSSet *)values;
- (void)removePhotosTaken:(NSSet *)values;

@end
