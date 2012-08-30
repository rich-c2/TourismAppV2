//
//  Guide.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Photo, Tag, User;

@interface Guide : NSManagedObject

@property (nonatomic, retain) NSString * frontEndURL;
@property (nonatomic, retain) NSString * guideID;
@property (nonatomic, retain) NSString * imageIDs;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) User *author;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *followedBy;
@property (nonatomic, retain) Photo *photos;
@property (nonatomic, retain) Tag *tag;
@end

@interface Guide (CoreDataGeneratedAccessors)

- (void)addFollowedByObject:(User *)value;
- (void)removeFollowedByObject:(User *)value;
- (void)addFollowedBy:(NSSet *)values;
- (void)removeFollowedBy:(NSSet *)values;

@end
