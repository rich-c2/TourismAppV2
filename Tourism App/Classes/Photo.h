//
//  Photo.h
//  Tourism App
//
//  Created by Richard Lee on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Guide, Tag, User, Venue;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * isLoved;
@property (nonatomic, retain) NSNumber * isVouched;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * lovesCount;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * timeElapsed;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSNumber * verified;
@property (nonatomic, retain) NSNumber * vouchesCount;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *inGuides;
@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) Venue *venue;
@property (nonatomic, retain) User *whoTook;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addInGuidesObject:(Guide *)value;
- (void)removeInGuidesObject:(Guide *)value;
- (void)addInGuides:(NSSet *)values;
- (void)removeInGuides:(NSSet *)values;

@end
