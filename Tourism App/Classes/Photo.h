//
//  Photo.h
//  Tourism App
//
//  Created by Richard Lee on 7/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class City, Guide, Tag;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * lovesCount;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * vouchesCount;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) City *city;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *inGuides;
@property (nonatomic, retain) Tag *tag;
@property (nonatomic, retain) NSManagedObject *venue;
@end

@interface Photo (CoreDataGeneratedAccessors)

+ (Photo *)photoWithPhotoData:(NSDictionary *)photoData inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addCommentsObject:(NSManagedObject *)value;
- (void)removeCommentsObject:(NSManagedObject *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addInGuidesObject:(Guide *)value;
- (void)removeInGuidesObject:(Guide *)value;
- (void)addInGuides:(NSSet *)values;
- (void)removeInGuides:(NSSet *)values;

@end
