//
//  Tag.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * tagID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *forGuides;
@property (nonatomic, retain) NSSet *onPhoto;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addForGuidesObject:(Guide *)value;
- (void)removeForGuidesObject:(Guide *)value;
- (void)addForGuides:(NSSet *)values;
- (void)removeForGuides:(NSSet *)values;

- (void)addOnPhotoObject:(Photo *)value;
- (void)removeOnPhotoObject:(Photo *)value;
- (void)addOnPhoto:(NSSet *)values;
- (void)removeOnPhoto:(NSSet *)values;

+ (Tag *)tagWithID:(NSInteger)tagIDNum inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Tag *)tagWithTitle:(NSString *)tagTitle andID:(NSInteger)tagIDNum
inManagedObjectContext:(NSManagedObjectContext *)context;

@end
