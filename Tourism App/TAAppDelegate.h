//
//  TAAppDelegate.h
//  Tourism App
//
//  Created by Richard Lee on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const DEMO_PASSWORD;
extern NSString* const DEMO_USERNAME;
extern NSString* const API_ADDRESS;
extern NSString* const FRONT_END_ADDRESS;
extern NSString* const TEST_API_ADDRESS;

@class TAProfileVC;
@class TANotificationsVC;

@class JSONFetcher;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate> {
	
	// TEST Fetcher & login username
	JSONFetcher *loginFetcher;

	UITabBarController *tabBarController;
	
	TAProfileVC *profileVC;
	TANotificationsVC *notificationsVC;
	
	NSString *sessionToken;
	NSString *loggedInUsername;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, retain) UITabBarController *tabBarController;

@property (nonatomic, retain) TAProfileVC *profileVC; 
@property (nonatomic, retain) TANotificationsVC *notificationsVC;

@property (nonatomic, retain) NSString *sessionToken;
@property (nonatomic, retain) NSString *loggedInUsername;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)setToken:(NSString *)token;

- (NSMutableURLRequest *)createPostRequestWithURL:(NSURL *)url postData:(NSData *)postData;
- (NSURL *)createRequestURLWithMethod:(NSString *)methodName testMode:(BOOL)test;

@end
