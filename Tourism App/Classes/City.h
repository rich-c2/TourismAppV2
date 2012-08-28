//
//  City.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Guide, Photo;

@interface City : NSManagedObject

@property (nonatomic, retain) NSString * cityID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *locationForGuide;
@property (nonatomic, retain) NSSet *photosTakenHere;
@end

@interface City (CoreDataGeneratedAccessors)

- (void)addLocationForGuideObject:(Guide *)value;
- (void)removeLocationForGuideObject:(Guide *)value;
- (void)addLocationForGuide:(NSSet *)values;
- (void)removeLocationForGuide:(NSSet *)values;

- (void)addPhotosTakenHereObject:(Photo *)value;
- (void)removePhotosTakenHereObject:(Photo *)value;
- (void)addPhotosTakenHere:(NSSet *)values;
- (void)removePhotosTakenHere:(NSSet *)values;

+ (City *)cityWithTitle:(NSString *)cityTitle inManagedObjectContext:(NSManagedObjectContext *)context;

@end
