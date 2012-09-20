//
//  TAScrollVC.m
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAScrollVC.h"
#import "Photo.h"
#import "User.h"
#import "SVProgressHUD.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "TAAppDelegate.h"
#import "TACommentsVC.h"
#import "TAMapVC.h"
#import "TAUsersVC.h"
#import "TAProfileVC.h"

#define IMAGE_WIDTH 320
#define IMAGE_HEIGHT 320
#define IMAGE_PADDING 0
#define IMAGE_VIEW_TAG 7000
#define SCREEN_WIDTH 320

@interface TAScrollVC ()

@end

@implementation TAScrollVC

@synthesize photosScrollView, photos, loveBtn, loveIDs, vouchedIDs;
@synthesize mainView, flipToView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        
		[self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
    self.photos = [NSMutableArray array];
	self.loveIDs = [NSMutableArray array];
	self.vouchedIDs = [NSMutableArray array];
	
	// The fetch size for each API call
    fetchSize = 20;
	
	UIImageView *flipView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 301.0, 301.0)];
	[flipView setImage:[UIImage imageNamed:@"test-photo-back.png"]];
	self.flipToView = flipView;
	[flipView release];
	
	UIImageView *mv = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 301.0, 301.0)];
	[mv setImage:[UIImage imageNamed:@"test-photo-view.png"]];
	self.mainView = mv;
	[mv release];
	
	[self.photosScrollView addSubview:self.mainView];
	[self.mainView release];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Flip" style:UIBarButtonItemStyleDone target:self 
															  action:@selector(flipAction:)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
	
	self.loveBtn = nil;
	self.photosScrollView = nil;
	self.photos = nil;
	self.loveIDs = nil;
	self.vouchedIDs = nil;
	
	self.mainView = nil; 
	self.flipToView = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {

	[loveIDs release];
	[loveBtn release];
	[photosScrollView release];
	[photos release];
	[vouchedIDs release];
	
	[mainView release]; 
	[flipToView release];
	
	[super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	//if (!loading && !photosLoaded) {
	
		//[self initFeedAPI];
	//}
}


#pragma PhotoFameDelegate methods 

- (void)usernameButtonClicked {

	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:[[currPhoto whoTook] username]];
	
	[self.navigationController pushViewController:profileVC animated:YES];
	[profileVC release];
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// Share on Twitter
	if (buttonIndex == 0) [self showTweetSheet:nil];
	
	// Vouch
	else if (buttonIndex == 1) {
		
		Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
		BOOL isVouched = (([self.vouchedIDs containsObject:[currPhoto photoID]]) ? YES : NO);
		
		[self showLoading];
		
		if (isVouched)[self initUnvouchAPI:[currPhoto photoID]];
		else [self initVouchAPI:[currPhoto photoID]];
	}
	
	// Flag
	else if (buttonIndex == 2) {
		
		Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
		
		[self initFlagAPI:[currPhoto photoID]];
	}
}


#pragma Twitter Framework methods

- (IBAction)showTweetSheet:(id)sender {
	
    //  Create an instance of the Tweet Sheet
    TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
	
    // Sets the completion handler.  Note that we don't know which thread the
    // block will be called on, so we need to ensure that any UI updates occur
    // on the main queue
    tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
		
		NSString *resultOutput;
		
        switch(result) {
				
            case TWTweetComposeViewControllerResultCancelled:
				
                //  This means the user cancelled without sending the Tweet
				resultOutput = @"Tweet cancelled.";
                break;
				
            case TWTweetComposeViewControllerResultDone:
				
                //  This means the user hit 'Send'
				resultOutput = @"You successfully shared this photo on Twitter.";
                break;
        }
		
		[self performSelectorOnMainThread:@selector(displayTweetResult:) withObject:resultOutput waitUntilDone:NO];
		
        //  dismiss the Tweet Sheet 
        dispatch_async(dispatch_get_main_queue(), ^{            
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Tweet Sheet has been dismissed."); 
            }];
        });
    };
	
    //  Set the initial body of the Tweet
    [tweetSheet setInitialText:@"Check out this photo on Tourism App:"]; 
	
	
	NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
	TAPhotoFrame *photoFrame = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
	
    //  Adds an image to the Tweet
    if (![tweetSheet addImage:[photoFrame.imageView image]]) {
        NSLog(@"Unable to add the image!");
    }
	
    //  Add an URL to the Tweet. You can add multiple URLs.
    /*if (![tweetSheet addURL:[NSURL URLWithString:@"http://twitter.com/"]]){
	 NSLog(@"Unable to add the URL!");
	 }*/
	
    //  Presents the Tweet Sheet to the user
    [self presentViewController:tweetSheet animated:NO completion:^{
        NSLog(@"Tweet sheet has been presented.");
    }];
}


- (void)displayTweetResult:(NSString *)output {
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Twitter" message:output delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[av show];
	[av release];
}


#pragma UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	// Need to detect if the scroll point has reached a new 
	// image. If so - start downloading this image, if it needs
	// to be downloaded or retrieved.
	NSInteger newIndex = ((int)scrollView.contentOffset.x / (IMAGE_WIDTH));
	
	if (newIndex != scrollIndex) { 
		
		scrollIndex = newIndex;
		
		// Use the index and convert it to a tag using the IMAGES_TAG as
		// the base. Use the tag to access the relevant ImageView
		// and initialise image download
		NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
		TAPhotoFrame *imageView = (TAPhotoFrame *)[self.photosScrollView viewWithTag:imageViewTag];
		[imageView initImage];
		
		// Update the selectedImageID
		//self.selectedImageID = [imageView imageID];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	if ([self.loveIDs containsObject:[currPhoto photoID]])
		[self.loveBtn setTitle:@"Unlove"];
	
	else [self.loveBtn setTitle:@"Love"];
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	[self showLoading];
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	[self initRecommendAPI:usernames forImage:[currPhoto photoID]];
}


- (void)initRecommendAPI:(NSMutableArray *)usernames forImage:(NSString *)imageID {
	
	NSString *usernamesStr = [NSString stringWithFormat:@"%@", [usernames componentsJoinedByString:@","]];
	
	NSString *postString = [NSString stringWithFormat:@"token=%@&username=%@&code=%@&usernames=%@", [[self appDelegate] sessionToken], [self appDelegate].loggedInUsername, imageID, usernamesStr];
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Recommend"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	recommendFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													  receiver:self
														action:@selector(receivedRecommendResponse:)];
	[recommendFetcher start];
	
}


// Example fetcher response handling
- (void)receivedRecommendResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == recommendFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		NSLog(@"jsonString RECOMMEND:%@", jsonString);
		
		[jsonString release];
	}
	
	[self hideLoading];
	
	[recommendFetcher release];
	recommendFetcher = nil;
    
}


#pragma MY METHODS

/*
 This function is responsible for 
 iterating through the self.images on hand, creating
 the necessary ImageViews and then position them
 in the timelineScrollView
 */
- (void)populateTimeline {
	
	CGFloat xPos = 0.0;
	CGFloat yPos = 10.0;
	CGFloat sViewContentHeight = yPos;
	
	for (int i = 0; i < [self.photos count]; i++) {
		
		Photo *photo = [self.photos objectAtIndex:i];
		NSString *imageURL = [photo url];
		
		CGRect viewFrame = CGRectMake(xPos, yPos, IMAGE_WIDTH, 357.0);
		TAPhotoFrame *photoView = [[TAPhotoFrame alloc] initWithFrame:viewFrame imageURL:imageURL caption:[photo caption] username:[[photo whoTook] username] avatarURL:[[photo whoTook] avatarURL]];
		[photoView setDelegate:self];
		
		[photoView setTag:(IMAGE_VIEW_TAG + i)];
		
		if (i == 0) [photoView initImage];
		
		[self.photosScrollView addSubview:photoView];
		[photoView release];
		
		xPos += (IMAGE_WIDTH + IMAGE_PADDING);
		sViewContentHeight = yPos;
	}
	
	CGFloat newHeight = self.photosScrollView.frame.size.height;
	CGFloat newWidth = xPos;
	
	// Update the scroll view's content height
	[self.photosScrollView setContentSize:CGSizeMake(newWidth, newHeight)];
	
	[self hideLoading];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initFeedAPI {
	
	loading = YES;
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i&token=%@", [self appDelegate].loggedInUsername, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Feed"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	feedFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFeedResponse:)];
	[feedFetcher start];
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == feedFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		photosLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString JSONValue];
		[jsonString release];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		//[self.images addObjectsFromArray:imagesArray];
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		//NSLog(@"IMAGES:%@", self.images);
		
		[self userUploadsRequestFinished];
    }
	
	// hide loading
	[self hideLoading];
    
    [feedFetcher release];
    feedFetcher = nil;
}


- (void)userUploadsRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self populateTimeline];
}


/*
 Iterates through the self.images array,  
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
	
	NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
	
	for (NSDictionary *image in imagesArray) {
		
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:context];
		if (photo) [self.photos addObject:photo];
		
		// Add image code to lovedIDs if it "isLoved"
		NSString *isLoved = [image objectForKey:@"isLoved"];
		
		if ([isLoved isEqualToString:@"true"]) 
			[self.loveIDs addObject:[image objectForKey:@"code"]];

		
		// Add image code to vouchedIDs if it "isVouched"
		NSString *isVouched = [image objectForKey:@"isVouched"];
		
		if ([isVouched isEqualToString:@"true"]) 
			[self.vouchedIDs addObject:[image objectForKey:@"code"]];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
    NSArray *photoFrames = [[self.photosScrollView subviews] retain];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [photoFrames count]; i++) {
		
		TAPhotoFrame *photo = [[photoFrames objectAtIndex: i] retain];
		
        if ([photo respondsToSelector:selector])
			[photo performSelector:selector withObject:image withObject:url];
		
        [photo release];
		photo = nil;
    }
	
    [photoFrames release];
}


- (IBAction)loveButtonTapped:(id)sender {

	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];
	
	if ([self.loveIDs containsObject:[currPhoto photoID]])
		[self initUnloveAPI:[currPhoto photoID]];
	
	else [self initLoveAPI:[currPhoto photoID]];
}


- (IBAction)commentButtonTapped:(id)sender {
	
	Photo *currPhoto = [self.photos objectAtIndex:scrollIndex];

	TACommentsVC *commentsVC = [[TACommentsVC alloc] initWithNibName:@"TACommentsVC" bundle:nil];
	[commentsVC setImageCode:[currPhoto photoID]];
	
	[self.navigationController pushViewController:commentsVC animated:YES];
	[commentsVC release];
}


- (IBAction)mapButtonTapped:(id)sender {

	Photo *photo = [self.photos objectAtIndex:scrollIndex];
	NSDictionary *locationData = [NSDictionary dictionaryWithObjectsAndKeys:[photo latitude], @"latitude", [photo longitude], @"longitude", nil];
	
	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setLocationData:locationData];
	[mapVC setMapMode:MapModeSingle];
	
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


- (IBAction)recommendButtonTapped:(id)sender {

	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
	[usersVC release];
}


- (IBAction)moreButtonTapped:(id)sender {
	
	Photo *photo = [self.photos objectAtIndex:scrollIndex];
	
	NSString *vouchStatus = (([self.vouchedIDs containsObject:[photo photoID]]) ? @"Unvouch" : @"Vouch");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Twitter", vouchStatus, @"Flag", nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    [actionSheet release];
}


- (void)initLoveAPI:(NSString *)photoID {

	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [self appDelegate].sessionToken];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithFormat:@"Love"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	loveFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedLoveResponse:)];
	[loveFetcher start];
}


- (void)initUnloveAPI:(NSString *)photoID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [self appDelegate].sessionToken];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithFormat:@"Unlove"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	loveFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedUnloveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedLoveResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success;
	NSString *imageID;
	NSString *newLovesCount;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		if ([[results allKeys] containsObject:@"count"])
			newLovesCount = [results objectForKey:@"count"];
		
		NSLog(@"receivedLoveResponse:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) {
		
		// Update Photo object?
		//Photo *photo = [self.imagesDictionary objectForKey:imageID];
		
		//[photo setIsLoved:[NSNumber numberWithInt:1]];
		//[photo setLovesCount:[NSNumber numberWithInt:[newLovesCount intValue]]];
		
		// Update loveIDs array
		[self.loveIDs addObject:imageID];
	}
	
	[loveFetcher release];
	loveFetcher = nil;
}


// Example fetcher response handling
- (void)receivedUnLoveResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success;
	NSString *imageID;
	NSString *newLovesCount;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		if ([[results allKeys] containsObject:@"count"])
			newLovesCount = [results objectForKey:@"count"];
		
		NSLog(@"receivedUnLoveResponse:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) {
		
		/*Photo *photo = [self.imagesDictionary objectForKey:imageID];
		
		[photo setIsLoved:[NSNumber numberWithInt:0]];
		[photo setLovesCount:[NSNumber numberWithInt:[newLovesCount intValue]]];*/
		
		// Update loveIDs array
		[self.loveIDs removeObject:imageID];
		
	}
	
	[loveFetcher release];
	loveFetcher = nil;
}


- (void)initFlagAPI:(NSString *)imageID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, imageID, [[self appDelegate] sessionToken]];	
	
	NSLog(@"FLAG DATA:%@", jsonString);
	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Flag"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	flagFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedFlagResponse:)];
	[flagFetcher start];
}


// Example fetcher response handling
- (void)receivedFlagResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == flagFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		//NSDictionary *results = [jsonString JSONValue];
		
		//if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString FLAG:%@", jsonString);
		
		[jsonString release];
	}
	
	[self hideLoading];
	
	[flagFetcher release];
	flagFetcher = nil;
    
}


// TESTED!
- (void)initVouchAPI:(NSString *)photoID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [[self appDelegate] sessionToken]];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Vouch"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	vouchFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedVouchResponse:)];
	[vouchFetcher start];
}


// Example fetcher response handling
- (void)receivedVouchResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == vouchFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	NSString *imageID;
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		imageID = [results objectForKey:@"code"];
		
		NSLog(@"VOUCH jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) {
		
		/*
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		[photo setIsVouched:[NSNumber numberWithInt:1]];
		*/
		
		// Update vouchedIDs array
		[self.vouchedIDs addObject:imageID];
	}
	
	[self hideLoading];
	
	[vouchFetcher release];
	vouchFetcher = nil;
    
}


// TESTED!
- (void)initUnvouchAPI:(NSString *)photoID {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, photoID, [[self appDelegate] sessionToken]];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Unvouch"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	vouchFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self action:@selector(receivedUnvouchResponse:)];
	[vouchFetcher start];
}


// Example fetcher response handling
- (void)receivedUnvouchResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == vouchFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	NSString *imageID;
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		imageID = [results objectForKey:@"code"];
		
		NSLog(@"UNVOUCH jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) {
		
		/*
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		[photo setIsVouched:[NSNumber numberWithInt:0]];*/
		
		// Update vouchedIDs array
		[self.vouchedIDs removeObject:imageID];
	}
	
	[self hideLoading];
	
	[vouchFetcher release];
	vouchFetcher = nil;
}


- (void)flipAction:(id)sender {		
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationBeginsFromCurrentState:YES];
	
	[UIView setAnimationTransition:([self.mainView superview] ?
									UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight)
									forView:self.photosScrollView cache:YES];
	if ([self.flipToView superview]) {
		
		[self.flipToView retain];
		[self.flipToView removeFromSuperview];
		[self.photosScrollView addSubview:mainView];
	}
	
	else {
		
		[self.mainView retain];
		[self.mainView removeFromSuperview];
		
		[self.photosScrollView addSubview:self.flipToView];
	}
	
	[UIView commitAnimations];
}

@end
