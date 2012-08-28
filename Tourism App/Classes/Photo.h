//
//  Photo.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * lovesCount;
@property (nonatomic, retain) NSString * photoID;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * vouchesCount;
@property (nonatomic, retain) NSManagedObject *city;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) NSSet *inGuides;
@property (nonatomic, retain) NSManagedObject *tag;
@property (nonatomic, retain) NSManagedObject *venue;
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
