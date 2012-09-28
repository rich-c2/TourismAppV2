//
//  TAAppDelegate.h
//  Tourism App
//
//  Created by Richard Lee on 13/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const DEMO_PASSWORD;
extern NSString* const DEMO_USERNAME;
extern NSString* const API_ADDRESS;
extern NSString* const FRONT_END_ADDRESS;
extern NSString* const TEST_API_ADDRESS;

@class TAProfileVC;
@class TANotificationsVC;
@class TALoginVC;
@class TAFeedVC;
@class TACameraVC;
@class TAExploreVC;
@class TALandingVC;

@interface TAAppDelegate : UIResponder <UIApplicationDelegate> {
	
	
	BOOL userLoggedIn;
	
	IBOutlet TALoginVC *loginVC;
	IBOutlet TALandingVC *landingVC;
	IBOutlet UINavigationController *landingNav;

	IBOutlet UITabBarController *tabBarController;
	
	TAFeedVC *feedVC;
	TAExploreVC *exploreVC;
	TACameraVC *cameraVC;
	TAProfileVC *profileVC;
	TANotificationsVC *notificationsVC;
	
	NSString *sessionToken;
	NSString *loggedInUsername;
}

@property (nonatomic) BOOL userLoggedIn;

@property (strong, nonatomic) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet TALoginVC *loginVC;
@property (nonatomic, retain) IBOutlet TALandingVC *landingVC;
@property (nonatomic, retain) IBOutlet UINavigationController *landingNav;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@property (nonatomic, retain) TAFeedVC *feedVC;
@property (nonatomic, retain) TAExploreVC *exploreVC;
@property (nonatomic, retain) TACameraVC *cameraVC;
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

- (NSArray *)serializeGuideData:(NSArray *)newGuides;

- (void)setTwitterUserID:(NSString *)newUserID;
- (void)setTwitterUsername:(NSString *)newUsername;
- (void)setTwitterAccountID:(NSString *)newAccountID;

- (NSString *)getTwitterUserID;
- (NSString *)getTwitterUsername;
- (NSString *)getTwitterAccountID;

@end
