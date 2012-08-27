//
//  Notification.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * type;

@end
