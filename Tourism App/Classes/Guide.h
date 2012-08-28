//
//  Guide.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Guide : NSManagedObject

@property (nonatomic, retain) NSString * frontEndURL;
@property (nonatomic, retain) NSString * guideID;
@property (nonatomic, retain) NSString * imageIDs;
@property (nonatomic, retain) NSNumber * private;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSManagedObject *author;
@property (nonatomic, retain) NSManagedObject *city;
@property (nonatomic, retain) NSSet *followedBy;
@property (nonatomic, retain) NSManagedObject *photos;
@property (nonatomic, retain) NSManagedObject *tag;
@end

@interface Guide (CoreDataGeneratedAccessors)

- (void)addFollowedByObject:(NSManagedObject *)value;
- (void)removeFollowedByObject:(NSManagedObject *)value;
- (void)addFollowedBy:(NSSet *)values;
- (void)removeFollowedBy:(NSSet *)values;

+ (Guide *)guideWithGuideData:(NSDictionary *)guideData inManagedObjectContext:(NSManagedObjectContext *)context;

@end
