//
//  TATimelineVC.m
//  Tourism App
//
//  Created by Richard Lee on 5/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TATimelineVC.h"
#import "TAAppDelegate.h"
#import "ImageView.h"
#import "SVProgressHUD.h"
#import "TAProfileVC.h"
#import "TASimpleListVC.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "TACommentsVC.h"
#import "TAMapVC.h"
#import "TAGuidesListVC.h"
#import "TAImageGridVC.h"
#import "Tag.h"
#import "TAUsersVC.h"
#import "Photo.h"
#import "City.h"
#import "User.h"

#define IMAGE_HEIGHT 480
#define IMAGE_PADDING 30
#define IMAGE_VIEW_TAG 7000
#define SCREEN_WIDTH 320

@interface TATimelineVC ()

@end

@implementation TATimelineVC

@synthesize timelineScrollView, selectedImageID, managedObjectContext;
@synthesize images, addToGuideBtn, imagesDictionary, photos;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	self.managedObjectContext = [self appDelegate].managedObjectContext;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate
{
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
    [timelineScrollView release];
    timelineScrollView = nil;
	
	self.selectedImageID = nil;
	self.images = nil;
	self.photos = nil;
	self.addToGuideBtn = nil;
	self.imagesDictionary = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
	[photos release];
	[imagesDictionary release];
	[addToGuideBtn release];
	[selectedImageID release];
	[images release];
    [timelineScrollView release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	
	if (!loaded && !loading) {
		
		loading = YES;
		
		loadedTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(isDataLoaded:) userInfo:nil repeats:YES];
		
		[self showLoading];
		
		[self createDataProperties];
		
		[self populateTimeline];
	}
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
	
	[self showLoading];
	
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	[self initRecommendAPI:usernames forImage:self.selectedImageID];
}


# pragma UIScrollViewDelegate methods 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	
	self.navigationItem.rightBarButtonItem = nil;
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

	self.navigationItem.rightBarButtonItem = self.addToGuideBtn;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	// Need to detect if the scroll point has reached a new 
	// image. If so - start downloading this image, if it needs
	// to be downloaded or retrieved.
	NSInteger newIndex = ((int)scrollView.contentOffset.y / (IMAGE_HEIGHT + IMAGE_PADDING));
	
	if (newIndex > scrollIndex) { 
		
		scrollIndex = newIndex;
		
		// Use the index and convert it to a tag using the IMAGES_TAG as
		// the base. Use the tag to access the relevant ImageView
		// and initialise image download
		NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
		ImageView *imageView = (ImageView *)[self.timelineScrollView viewWithTag:imageViewTag];
		[imageView initImage];
		
		// Update the selectedImageID
		self.selectedImageID = [imageView imageID];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	self.navigationItem.rightBarButtonItem = self.addToGuideBtn;
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// Share on Twitter
	if (buttonIndex == 0) [self showTweetSheet:nil];
	
	// Vouch
	else if (buttonIndex == 1) {
		
		Photo *photo = [self.imagesDictionary objectForKey:self.selectedImageID];
		BOOL isVouched = (([photo.isVouched intValue] == 1) ? YES : NO);
		
		[self showLoading];
		
		if (isVouched)[self initUnvouchAPI];
		else [self initVouchAPI];
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
    [tweetSheet setInitialText:@"Check out the photo I took on Tourism App:"]; 
	
	
	NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
	ImageView *imageView = (ImageView *)[self.timelineScrollView viewWithTag:imageViewTag];
	
    //  Adds an image to the Tweet
    if (![tweetSheet addImage:[imageView.imageView image]]) {
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


#pragma ImageViewDelegate methods 

- (void)usernameButtonClicked:(NSString *)selectedUser {
	
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	[profileVC setUsername:selectedUser];
	
	[self.navigationController pushViewController:profileVC animated:YES];
	[profileVC release];
}


- (void)loveCountButtonClicked:(NSString *)imageID {
	
	TASimpleListVC *listVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[listVC setImageCode:imageID];
	[self.navigationController pushViewController:listVC animated:YES];
	[listVC release];
}


- (void)loveButtonClicked:(NSString *)imageID isLoved:(BOOL)loved {

	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, imageID, [self appDelegate].sessionToken];
	
	NSLog(@"newJSON:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithFormat:@"%@", ((loved) ? @"UnLove" : @"Love")];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	SEL selector;
	if ([methodName isEqualToString:@"Love"]) {
		
		selector = @selector(receivedLoveResponse:);
	}
	else {
		
		selector = @selector(receivedUnLoveResponse:);
	}
	
	// JSONFetcher
	loveFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:selector];
	[loveFetcher start];
}


- (void)commentButtonClicked:(NSString *)imageID {
	
	TACommentsVC *commentsVC = [[TACommentsVC alloc] initWithNibName:@"TACommentsVC" bundle:nil];
	[commentsVC setImageCode:imageID];
	
	[self.navigationController pushViewController:commentsVC animated:YES];
	[commentsVC release];
}


- (void)mapButtonClicked:(NSString *)imageID {

	Photo *photo = [self.imagesDictionary objectForKey:imageID];
	NSDictionary *locationData = [NSDictionary dictionaryWithObjectsAndKeys:[photo latitude], @"latitude", [photo longitude], @"longitude", nil];
	
	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setLocationData:locationData];
	[mapVC setMapMode:MapModeSingle];
	
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}


- (void)cityTagButtonClicked:(NSString *)imageID {
	
	Photo *photo = [self.imagesDictionary objectForKey:imageID];
	
	NSNumber *tagID = [photo.tag tagID];
	NSString *city = [[photo city] title];

	TAImageGridVC *imageGridVC = [[TAImageGridVC alloc] initWithNibName:@"TAImageGridVC" bundle:nil];
	[imageGridVC setImagesMode:ImagesModeCityTag];
	[imageGridVC setTagID:tagID];
	[imageGridVC setCity:city];

	[self.navigationController pushViewController:imageGridVC animated:YES];
	[imageGridVC release];
}


- (void)optionsButtonClicked:(NSString *)imageID {
	
	Photo *photo = [self.imagesDictionary objectForKey:imageID];
	
	NSString *vouchStatus = (([[photo isVouched] intValue] == 1) ? @"Unvouch" : @"Vouch");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Twitter", vouchStatus, nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    [actionSheet release];
}


- (void)recommendButtonClicked {
	
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
	[usersVC release];
}


/*
	This function is responsible for 
	iterating through the self.images on hand, creating
	the necessary ImageViews and then position them
	in the timelineScrollView
*/
- (void)populateTimeline {
	
	CGFloat xPos = 10.0;
	CGFloat yPos = 10.0;
	CGFloat aViewHeight = IMAGE_HEIGHT;
	CGFloat bottomPadding = IMAGE_PADDING;
	CGFloat sViewContentHeight = yPos;
	CGFloat selectedYPos;
	
	if ([[self.timelineScrollView subviews] count] > 0) {
		
		scrollIndex = 0;
		[self removeImageViews];
		[self.timelineScrollView setContentOffset:CGPointMake(0.0, 0.0)];
	}
	
	for (int i = 0; i < [self.photos count]; i++) {
		
		Photo *photo = [self.photos objectAtIndex:i];
		User *user = (User *)photo.whoTook; 
		NSString *imageID = [photo photoID];		
		
		NSInteger lovesCount = [[photo lovesCount] intValue];
		NSString *avatarURLString = user.avatarURL;
		NSLog(@"avatarURLString:%@", avatarURLString);
		
		NSString *city = [[photo city] title];
		Tag *tag = [photo tag];
		
		if ([imageID isEqualToString:self.selectedImageID]) {
			
			selectedYPos = yPos;
		}
		
		NSString *imageURL = [photo url];
		NSString *username = [photo username];
		NSString *avatarURL = avatarURLString;
		
		BOOL isLoved = [photo.isLoved intValue];
		NSString *timeElapsed = photo.timeElapsed;		
		BOOL verified = [photo.verified intValue];
		
		CGRect viewFrame = CGRectMake(xPos, yPos, 300.0, aViewHeight);
		ImageView *aView = [[ImageView alloc] initWithFrame:viewFrame imageURL:imageURL username:username avatarURL:avatarURL loves:lovesCount dateText:timeElapsed cityText:city tagText:tag.title verified:verified];
		
		[aView setImageID:imageID];
		[aView setUsername:username];
		[aView setDelegate:self];
		[aView isLoved:isLoved];
		
		[aView setTag:(IMAGE_VIEW_TAG + i)];
		
		if (i == 0) [aView initImage];
		
		NSLog(@"IMAGE ID:%@", imageID);
		
		[self.timelineScrollView addSubview:aView];
		[aView release];
		
		yPos += (aViewHeight + bottomPadding);
		sViewContentHeight = yPos;
	}
	
	imageViewsReady = YES;
	
	// Update the scroll view's content height
	[self.timelineScrollView setContentSize:CGSizeMake(SCREEN_WIDTH, sViewContentHeight)];
	
	// Focus on selected Image if there is one
	if ([self.selectedImageID length] > 0) {
		
		CGPoint newOffset = CGPointMake(0.0, (selectedYPos - (IMAGE_PADDING-20)));
		[self.timelineScrollView setContentOffset:newOffset animated:YES];
	}
	
	// Add submit button to the top nav bar
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleDone target:self action:@selector(addToGuide:)];
	buttonItem.target = self;
	
	self.addToGuideBtn = buttonItem;
	[buttonItem release];
	
	self.navigationItem.rightBarButtonItem = self.addToGuideBtn;
	
	loading = NO;
	
	[self hideLoading];
}


// Clear the ImageViews from the timelineScrollView
- (void)removeImageViews {
	
	for (ImageView *imageView in [self.timelineScrollView subviews]) {
		
		[imageView removeFromSuperview];
	}
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)isDataLoaded:(id)sender {
	
	if (!loading) {
		
		loaded = YES;
		
		[loadedTimer invalidate];
		loadedTimer = nil;
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
    NSArray *imageViews = [[self.timelineScrollView subviews] retain];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [imageViews count]; i++) {
		
		ImageView *imageView = [[imageViews objectAtIndex: i] retain];
		
        if ([imageView respondsToSelector:selector])
			[imageView performSelector:selector withObject:image withObject:url];
		
        [imageView release];
		imageView = nil;
    }
	
    [imageViews release];
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
		
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		
		[photo setIsLoved:[NSNumber numberWithInt:1]];
		[photo setLovesCount:[NSNumber numberWithInt:[newLovesCount intValue]]];
		
		[self updateImageViewWithImageID:imageID loveStatus:YES];
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
		
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		
		[photo setIsLoved:[NSNumber numberWithInt:0]];
		[photo setLovesCount:[NSNumber numberWithInt:[newLovesCount intValue]]];
		
		[self updateImageViewWithImageID:imageID loveStatus:NO];
		
	}
	
	[loveFetcher release];
	loveFetcher = nil;
}


- (void)updateImageViewWithImageID:(NSString *)imageID loveStatus:(BOOL)isLoved {
	
	for (ImageView *imageView in [self.timelineScrollView subviews]) { 
		
		if ([imageView.imageID isEqualToString:imageID]) {
			
			[imageView isLoved:isLoved];
			[imageView updateLovesCount:isLoved];
		}
	}
}


#define kMinute 60
#define kHour (60*60)
#define kDay (60*60*24)
- (NSString*)textFromSeconds:(double)seconds {
	
	if(seconds < kMinute)
		return [NSString stringWithFormat:@"%0.0fs",seconds];
	
	if(seconds < kHour)
		return [NSString stringWithFormat:@"%0.0fm",seconds/kMinute];
	
	if(seconds < kDay)
		return [NSString stringWithFormat:@"%0.0fh",seconds/kHour];
	
	return [NSString stringWithFormat:@"%0.0fd", seconds/kDay];
}


- (NSString *)textFromDate:(NSDate *)date {
	
	double seconds = [[NSDate date] timeIntervalSinceDate:date];
	NSString *text = [self textFromSeconds:seconds];
	
	return text;
}


- (void)addToGuide:(id)sender {

	// Use the index and convert it to a tag using the IMAGES_TAG as
	// the base. Use the tag to access the relevant ImageView
	// and initialise image download
	NSInteger imageViewTag = IMAGE_VIEW_TAG + scrollIndex;
	ImageView *imageView = (ImageView *)[self.timelineScrollView viewWithTag:imageViewTag];
	
	Photo *photo = [self.imagesDictionary objectForKey:[imageView imageID]];
	//NSDictionary *imageData = [self.imagesDictionary objectForKey:[imageView imageID]];
		
	TAGuidesListVC *guidesVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesVC setUsername:[self appDelegate].loggedInUsername];
	[guidesVC setGuidesMode:GuidesModeAddTo];
	[guidesVC setSelectedTagID:[photo.tag tagID]];
	[guidesVC setSelectedCity:[photo.city title]];
	[guidesVC setSelectedPhotoID:[photo photoID]];
	
	[self.navigationController pushViewController:guidesVC animated:YES];
	[guidesVC release];
}


- (void)createDataProperties {

	self.imagesDictionary = [NSMutableDictionary dictionary];
	
	for (Photo *photo in self.photos) {
	
		NSString *key = [photo photoID];
	
		[self.imagesDictionary setObject:photo forKey:key];
	}
}


// TESTED!
- (void)initVouchAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.selectedImageID, [[self appDelegate] sessionToken]];	
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
				
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		[photo setIsVouched:[NSNumber numberWithInt:1]];
	}
	
	[self hideLoading];
	
	[vouchFetcher release];
	vouchFetcher = nil;
    
}


// TESTED!
- (void)initUnvouchAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@", [self appDelegate].loggedInUsername, self.selectedImageID, [[self appDelegate] sessionToken]];	
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
		
		Photo *photo = [self.imagesDictionary objectForKey:imageID];
		[photo setIsVouched:[NSNumber numberWithInt:0]];
	}
	
	[self hideLoading];
	
	[vouchFetcher release];
	vouchFetcher = nil;
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
		
		// Create a dictionary from the JSON string
		//NSDictionary *results = [jsonString JSONValue];
		
		//if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString RECOMMEND:%@", jsonString);
		
		[jsonString release];
	}
	
	[self hideLoading];
	
	[recommendFetcher release];
	recommendFetcher = nil;
    
}


@end
