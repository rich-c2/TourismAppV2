//
//  Venue.h
//  Tourism App
//
//  Created by Richard Lee on 11/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Venue : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * venueID;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSSet *photosTakenHere;
@end

@interface Venue (CoreDataGeneratedAccessors)

+ (Venue *)venueWithData:(NSDictionary *)basicInfo location:(NSDictionary *)locationData inManagedObjectContext:(NSManagedObjectContext *)context;

- (void)addPhotosTakenHereObject:(Photo *)value;
- (void)removePhotosTakenHereObject:(Photo *)value;
- (void)addPhotosTakenHere:(NSSet *)values;
- (void)removePhotosTakenHere:(NSSet *)values;

@end
