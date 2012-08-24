//
//  TAAppDelegate.m
//  Tourism App
//
//  Created by Richard Lee on 13/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAAppDelegate.h"
#import "StringHelper.h"
#import "TAProfileVC.h"
#import "TANotificationsVC.h"
#import "TANotificationsManager.h"

#import "JSONFetcher.h"
#import "SBJson.h"

NSString* const DEMO_PASSWORD = @"pass";
NSString* const DEMO_USERNAME = @"fuzzyhead";
NSString* const API_ADDRESS = @"http://want.supergloo.net.au/api/";
NSString* const FRONT_END_ADDRESS = @"http://want.supergloo.net.au"; 
NSString* const TEST_API_ADDRESS = @"http://www.richardflee.me/test/";

@implementation TAAppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize profileVC, notificationsVC, tabBarController;
@synthesize sessionToken, loggedInUsername, testUsername;

- (void)dealloc {
	
	[notificationsVC release];
	[sessionToken release];
	[loggedInUsername release];
	[tabBarController release];
	[profileVC release];
	[_window release];
	[__managedObjectContext release];
	[__managedObjectModel release];
	[__persistentStoreCoordinator release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	// Setup any test/temporary data in here
	// FOR NOW, the log-in data iset in here
	[self initApp];
	
	// Add Feed tab
	
	// Add Explore tab
	
	// Add Share tab
	
	// Add News tab
	notificationsVC = [[TANotificationsVC alloc] initWithNibName:@"TANotificationsVC" bundle:nil];
	
	UINavigationController *navcon = [[UINavigationController alloc] init];
	[navcon.navigationBar setTintColor:[UIColor redColor]];
	[navcon pushViewController:notificationsVC animated:NO];
	[notificationsVC release];
	
	// Add Profile tab
	profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:@"rich"];
	
	UINavigationController *navcon2 = [[UINavigationController alloc] init];
	[navcon2.navigationBar setTintColor:[UIColor redColor]];
	[navcon2 pushViewController:profileVC animated:NO];
	[profileVC release];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
	
	// Create a tabbar controller and an array to contain the view controllers
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:5];
	[localViewControllersArray addObject:navcon2];
	[localViewControllersArray addObject:navcon];
	/*[localViewControllersArray addObject:navcon3];
	[localViewControllersArray addObject:navcon4];
	[localViewControllersArray addObject:navcon2];*/
	[navcon release];
	[navcon2 release];
	/*[navcon5 release];
	[navcon3 release];
	[navcon4 release];*/
	
	// set the tab bar controller view controller array to the localViewControllersArray
	tabBarController.viewControllers = localViewControllersArray;
	
	// the localViewControllersArray data is now retained by the tabBarController
	// so we can release this version
	[localViewControllersArray release];
	
	// Add the view controller's view to the window and display.
    //[self.window addSubview:[tabBarController view]];
	[self.window insertSubview:[self.tabBarController view] atIndex:0];
	
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tourism_App" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tourism_App.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


#pragma MY-METHODS

- (void)initApp {

	// test data. Delete this once login process 
	// has been implemented
	self.testUsername = @"stu";
	
	// TEST LOGIN
	[self login];
}


- (void)initNotificationsManager {

	// Initiate the notifications manager which polls the API for notifications
	TANotificationsManager *notificationsManager = [TANotificationsManager sharedManager];
	
	/*
     Register to receive change notifications for the "recommends" property of
     the 'notificationsManager' object and specify that both the old and new values of "recommends"
     should be provided in the observe… method.
     */
    [notificationsManager addObserver:self
						   forKeyPath:@"recommends"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
	
	[notificationsManager addObserver:self
						   forKeyPath:@"meItems"
							  options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
							  context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSString *message;
	NSInteger recommendations = 0;
	NSInteger meItems = 0;
	
    if ([keyPath isEqual:@"recommends"])
		recommendations = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	else if ([keyPath isEqual:@"meItems"])
		meItems = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	message = [NSString stringWithFormat:@"Received %i new recommendations and %i ME items", recommendations, meItems];
	
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"HEY" message:message delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
	[av show];
	[av release];
}

// The sessionToken property can be set here
// by passing it as an argument
- (void)setToken:(NSString *)token {
	
	self.sessionToken = token;
}

- (NSMutableURLRequest *)createPostRequestWithURL:(NSURL *)url postData:(NSData *)postData {
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = (NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	
	// Add the Authorization header with the credentials made above. 
	[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	[request setValue:[NSString stringWithFormat:@"%d", [postData length]] forHTTPHeaderField:@"Content-Length"];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postData];
	
	return request;
}


- (NSURL *)createRequestURLWithMethod:(NSString *)methodName testMode:(BOOL)test {
	
	NSString *api = (test ? TEST_API_ADDRESS : API_ADDRESS);
	
	// Create the URL that will be used to authenticate this user
	NSString *urlString = [NSString stringWithFormat:@"%@%@", api, methodName];
	
	// Print the URL to the console
	NSLog(@"URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	return url;
} 


#pragma LOGIN METHODS 

- (void)login {
	
	//[self showLoading];
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&password=%@", self.testUsername, @"pass"];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
    NSData *jsonData = [jsonString dataUsingEncoding:NSASCIIStringEncoding];
	
	NSURL *url = [self createRequestURLWithMethod:@"Login" testMode:NO];
    
    // Initialiase the URL Request
	NSMutableURLRequest *request = [self createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
    loginFetcher = [[JSONFetcher alloc] initWithURLRequest:request
											 receiver:self
											   action:@selector(receivedLoginResponse:)];
    [loginFetcher start];
}


// Example fetcher response handling
- (void)receivedLoginResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
	NSAssert(aFetcher == loginFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL loginSuccess = NO;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		for (int i = 0; i < [[results allKeys] count]; i++) {
			
			NSString *key = [[results allKeys] objectAtIndex:i];
			NSString *value = [results objectForKey:key];
			
			if ([key isEqualToString:@"result"]) loginSuccess = (([value isEqualToString:@"ok"]) ? YES : NO);
			
			// Pass the token value to the AppDelegate to be stored as 
			// the session token for all API calls
			else if ([key isEqualToString:@"token"]) [self setToken:[results objectForKey:key]];
		}
		
		[jsonString release];
	}
	
	NSString *message;
	
	// Login credentials were given the tick of approval by the API
	// tell the delegate to animate this form out
	if (loginSuccess) {
		
		message = @"Your login attempt was successful.";
		
		// Store logged-in username
		[self setLoggedInUsername:self.testUsername];
		
		// Init notifications manager 
		// This is a test setup for now. 
		[self initNotificationsManager];
	}
	
	else message = @"There was an error logging you in.";
	
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Login result"
														message:message
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
	[av show];
	[av release];

	[loginFetcher release];
	loginFetcher = nil;
    
}




@end
