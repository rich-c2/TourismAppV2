//
//  TANotificationsManager.m
//  Tourism App
//
//  Created by Richard Lee on 24/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TANotificationsManager.h"
#import "TAAppDelegate.h"
#import "JSONFetcher.h"
#import "StringHelper.h"
#import "SBJson.h"

@implementation TANotificationsManager

@synthesize recommends, meItems;

#pragma mark Singleton Methods

+ (id)sharedManager {
	
    static TANotificationsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init {
	
	if (self = [super init]) {
		
		recommends = [NSNumber numberWithInt:0];
		meItems = [NSNumber numberWithInt:0];
		
		// start timer for next API call
		[self initPollTimer];
	}
	return self;
}


- (void)initPollTimer {

	// Schedule timer to fire every 5 minutes. Target = initPollAPI.
	pollTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(initPollAPI) userInfo:nil repeats:YES];
}


- (void)initPollAPI {
	
	TAAppDelegate *appDelegate = [self appDelegate];

	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@", appDelegate.loggedInUsername, appDelegate.sessionToken];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"howzit"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	pollFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedPollResponse:)];
	[pollFetcher start];
}


// Example fetcher response handling
- (void)receivedPollResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSLog(@"POLL DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == pollFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//loading = NO;
	//feedLoaded = YES;
	
	if ([theJSONFetcher.data length] > 0 ) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		NSDictionary *notifications = [results objectForKey:@"notifications"];
		
		NSInteger numRecommendations = [[notifications objectForKey:@"recommendations"] intValue];
		NSInteger numMe = [[notifications objectForKey:@"me"] intValue];
		
		if (numRecommendations > 0) [self updateRecommendations:numRecommendations];
		if (numMe > 0) [self updateMe:numMe];
		
		//NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	[pollFetcher release];
	pollFetcher = nil;
}


- (void)updateRecommendations:(NSInteger)newRecommendations {

	NSInteger newTotal = [self.recommends intValue] + newRecommendations;
	self.recommends = [NSNumber numberWithInt:newTotal];
}


- (void)updateMe:(NSInteger)newMe {
	
	NSInteger newTotal = [self.meItems intValue] + newMe;
	self.meItems = [NSNumber numberWithInt:newTotal];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)dealloc {

	[recommends release];
	[meItems release];
	
	[super dealloc];
}

@end
