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

#define IMAGE_HEIGHT 415
#define IMAGE_PADDING 30
#define IMAGE_VIEW_TAG 7000
#define SCREEN_WIDTH 320

@interface TATimelineVC ()

@end

@implementation TATimelineVC

@synthesize timelineScrollView, selectedImageID;
@synthesize images;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
	
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
		
		[self populateTimeline];
		
		//[self fetchLovedImages];
	}
}


# pragma UIScrollViewDelegate methods 

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
	}
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
	
	for (int i = 0; i < [self.images count]; i++) {
		
		NSDictionary *image = [self.images objectAtIndex:i];
		NSString *imageID = [image objectForKey:@"code"];		
		
		NSDictionary *countDict = [image objectForKey:@"count"];
		NSInteger lovesCount = [[countDict objectForKey:@"loves"] intValue];
		
		NSDictionary *userDict = [image objectForKey:@"user"];		
		NSString *avatarURLString = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [userDict objectForKey:@"avatar"]];
		
		NSString *city = [image objectForKey:@"city"];
		NSString *tag = [image objectForKey:@"tag"];
		
		
		if ([[image objectForKey:@"code"] isEqualToString:self.selectedImageID]) {
			
			NSLog(@"SELECTED IMAGE:%@", image);
			selectedYPos = yPos;
		}
		
		NSDictionary *pathsDict = [image objectForKey:@"paths"];
		NSString *imageURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [pathsDict objectForKey:@"zoom"]];
		NSString *username = [userDict objectForKey:@"username"];
		NSString *avatarURL = avatarURLString;
		
		NSString *timeElapsed = [image objectForKey:@"elapsed"];
		
		CGRect viewFrame = CGRectMake(xPos, yPos, 300.0, aViewHeight);
		ImageView *aView = [[ImageView alloc] initWithFrame:viewFrame imageURL:imageURL username:username avatarURL:avatarURL loves:lovesCount dateText:timeElapsed cityText:city tagText:tag];

		
		[aView setImageID:imageID];
		[aView setUsername:username];
		[aView setDelegate:self];
		
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
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) [self updateImageViewWithImageID:imageID loveStatus:YES];
	
	[loveFetcher release];
	loveFetcher = nil;
    
}


// Example fetcher response handling
- (void)receivedUnLoveResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success;
	NSString *imageID;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		if ([[results allKeys] containsObject:@"code"])
			imageID = [results objectForKey:@"code"];
		
		NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
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


@end
