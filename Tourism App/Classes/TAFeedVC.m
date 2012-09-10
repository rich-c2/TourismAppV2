//
//  TAFeedVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAFeedVC.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "TAAppDelegate.h"
#import "GridImage.h"
#import "SVProgressHUD.h"
#import "TAImageDetailsVC.h"
#import "TATimelineVC.h"
#import "Photo.h"


#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 75.0
#define GRID_IMAGE_HEIGHT 75.0
#define IMAGE_PADDING 4.0
#define MAIN_CONTENT_HEIGHT 367.0

static NSString *kUserDefaultCityKey = @"userDefaultCityKey";

@interface TAFeedVC ()

@end

@implementation TAFeedVC

@synthesize imagesView, gridScrollView;
@synthesize images, feedMode, photos;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
		
		// Observe when the user has actually logged-in
		// so we can then start loading data
		[self initLoginObserver];
        
		self.title = @"Feed";
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	self.images = [NSMutableArray array];
	self.photos = [NSMutableArray array];
	
	// The fetch size for each API call
    fetchSize = 20;
	
	// Add a bar button item to the top-right of the navigation
	// bar that will trigeer an Action Sheet containing the different
	// view mode options
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"mode" style:UIBarButtonItemStyleDone target:self action:@selector(viewModeButtonTapped:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	[buttonItem release];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	self.images = nil;
	self.photos = nil;
	
    [gridScrollView release];
    self.gridScrollView = nil;
    [imagesView release];
    self.imagesView = nil;
	
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
}


#pragma UIScrollViewDelegate methods 

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

	NSInteger yOffset = (int)scrollView.contentOffset.y;
	NSInteger height = (int)scrollView.contentSize.height;
	NSInteger differential = height - yOffset;
	
	//NSLog(@"yOffset:%i|height:%i|differential:%i", yOffset, height, differential);
	
	if (differential == MAIN_CONTENT_HEIGHT) {
		
		NSLog(@"FRESH");
		
		refresh = YES;
	}
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	
	// If the scroll view has reach the "refresh" point
	// and more images are not currently being
	// loaded, then load more images
	if (refresh && !loading){
		
		NSLog(@"REFRESSHHHHHHHH");
		
		[self loadMoreImages];
	}
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

	NSLog(@"REFRESH IS:%@", ((refresh) ? @"YES" : @"NO"));
	
	refresh = NO;
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	
	// Feed
	if (buttonIndex == 0) {
		
		// Check that we're not already in "feed mode" before updating
		if (self.feedMode != FeedModeFeed) {
			
			[self showLoading];
			
			self.feedMode = FeedModeFeed;
			[self refreshButtonClicked:nil];
		}
	}
	
	// Default city
	else if (buttonIndex == 1) { 
		
		// Check that we're not already in "default city mode" before updating
		if (self.feedMode != FeedModeCity) {
		
			[self showLoading];
			
			self.feedMode = FeedModeCity;
			[self refreshButtonClicked:nil];
		}
	}
	
	// Refresh
	else if (buttonIndex == 2) { 
	
		[self showLoading];
		[self refreshButtonClicked:nil];
	}
}


#pragma GridImageDelegate methods 

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	//NSDictionary *image = [self.images objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	Photo *photo = [self.photos objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	// Push the TATimelineVC onto the stack
	TATimelineVC *timelineVC = [[TATimelineVC alloc] initWithNibName:@"TATimelineVC" bundle:nil];
	[timelineVC setPhotos:self.photos];
	[timelineVC setSelectedImageID:[photo photoID]];
	
	[self.navigationController pushViewController:timelineVC animated:YES];
	[timelineVC release];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	NSArray *gridImages = [[self.imagesView subviews] retain];
	SEL selector = @selector(imageLoaded:withURL:);
	
	for (int i = 0; i < [gridImages count]; i++) {
		
		GridImage *gridImage = [[gridImages objectAtIndex: i] retain];
		
		if ([gridImage respondsToSelector:selector])
			[gridImage performSelector:selector withObject:image withObject:url];
		
		[gridImage release];
		gridImage = nil;
	}
	
	[gridImages release];
}


#pragma MY-METHODS

- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (void)initLoginObserver {
	
	// Get an iVar of TAAppDelegate
	TAAppDelegate *appDelegate = [self appDelegate];
	
	/*
     Register to receive change notifications for the "userLoggedIn" property of
     the 'appDelegate' and specify that both the old and new values of "userLoggedIn"
     should be provided in the observe… method.
     */
    [appDelegate addObserver:self
				  forKeyPath:@"userLoggedIn"
					 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
					 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSInteger loggedIn = 0;
	
    if ([keyPath isEqual:@"userLoggedIn"])
		loggedIn = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	
	if (loggedIn == 1) {
		
		[self showLoading];
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		[self removeThumbnails];
		
		// Clear images array
		[self.images removeAllObjects];
		
		// Load the FEED from the API
		self.feedMode = FeedModeFeed;
		[self initFeedAPI];
		
		// Get an iVar of TAAppDelegate
		// and STOP observing the AppDelegate's userLoggedIn
		// property now that the user HAS logged-in
		//TAAppDelegate *appDelegate = [self appDelegate];
		//[appDelegate removeObserver:self forKeyPath:@"userLoggedIn"];
	}
}


- (void)viewModeButtonTapped:(id)sender {
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feed", @"Default city", @"Refresh", nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    [actionSheet release];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.imagesView.frame.size.width;
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;
	
	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add, and how many have already
	// been added previously
	NSInteger subviewsCount = [self.imagesView.subviews count];
	
	// Set what the next tag value should be
	NSInteger tagCounter = IMAGE_VIEW_TAG + subviewsCount;
	
	// If images have previously been added, calculate where to 
	// start placing the next batch of images
	if (subviewsCount > 0) {
		
		NSInteger rowCount = subviewsCount/4;
		NSInteger leftOver = subviewsCount%4;
		
		// Calculate starting xPos & yPos
		xPos = (leftOver * (GRID_IMAGE_WIDTH + IMAGE_PADDING));
		yPos = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	}
	
	for (int i = subviewsCount; i < [self.photos count]; i++) {
		
		// Retrieve Photo object from array, and construct
		// a URL string for the thumbnail image
		Photo *photo = [self.photos objectAtIndex:i];
		NSString *thumbURL = [photo thumbURL];
		
		// Create GridImage, set its Tag and Delegate, and add it 
		// to the imagesView
		CGRect newFrame = CGRectMake(xPos, yPos, GRID_IMAGE_WIDTH, GRID_IMAGE_HEIGHT);
		GridImage *gridImage = [[GridImage alloc] initWithFrame:newFrame imageURL:thumbURL];
		[gridImage setTag:tagCounter];
		[gridImage setDelegate:self];
		[self.imagesView addSubview:gridImage];
		[gridImage release];
		
		// Update xPos & yPos for new image
		xPos += (GRID_IMAGE_WIDTH + IMAGE_PADDING);
		
		// Update tag for next image
		tagCounter++;
		
		if (xPos > maxXPos) {
			
			xPos = startXPos;
			yPos += (GRID_IMAGE_HEIGHT + IMAGE_PADDING);
		}
	}
	
	// Update size of the relevant views
	[self updateGridLayout];
}


- (void)updateGridLayout {
	
	// Updated number of how many rows there are
	NSInteger rowCount = [[self.imagesView subviews] count]/4;
	NSInteger leftOver = [[self.imagesView subviews] count]%4;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGRect imagesViewFrame = self.imagesView.frame;
	CGFloat gridRowsHeight = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	
	CGFloat sViewContentHeight = imagesViewFrame.origin.y + gridRowsHeight + IMAGE_PADDING;
	
	// Set image view frame height
	imagesViewFrame.size.height = gridRowsHeight;
	[self.imagesView setFrame:imagesViewFrame];
	
	// Adjust content height of the scroll view
	[self.gridScrollView setContentSize:CGSizeMake(self.gridScrollView.frame.size.width, sViewContentHeight)];
}


- (void)initLatestAPI {
	
	loading = YES;
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"pg=%i&sz=%i", imagesPageIndex, fetchSize];	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Latest"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedLatestResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedLatestResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        imagesLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString JSONValue];
		[jsonString release];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		[self.images addObjectsFromArray:imagesArray];
		
		NSLog(@"IMAGES:%@", self.images);
		
		[self userUploadsRequestFinished];
    }
	
	// hide loading
	[self hideLoading];
    
    [imagesFetcher release];
    imagesFetcher = nil;
}


- (void)userUploadsRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)initFindMediaAPI {
	
	loading = YES;
	
	NSString *defaultCity = [self getUsersDefaultCity];
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&city=%@&pg=%i&sz=%i&token=%@", [self appDelegate].loggedInUsername, defaultCity, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	
	NSLog(@"CITY PARAMETERS:%@", jsonString);
	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindMedia"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindMediaResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedFindMediaResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING DATA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		imagesLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString JSONValue];
		[jsonString release];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		[self.images addObjectsFromArray:imagesArray];
		
		NSLog(@"CITY COUNT:%i", [self.images count]);
		
		[self userUploadsRequestFinished];
    }
    
	// hide loading
	[self hideLoading];
	
    [imagesFetcher release];
    imagesFetcher = nil;
}


- (void)initPopularAPI {
	
	loading = YES;
	
	// Convert string to data for transmission
	NSString *jsonString = [NSString stringWithFormat:@"pg=%i&sz=%i", imagesPageIndex, fetchSize];	
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Popular"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedPopularResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedPopularResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        imagesLoaded = YES;
		
		// Store incoming data into a string
		// Create a dictionary from the JSON string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		NSDictionary *results = [jsonString JSONValue];
		[jsonString release];
		
		NSArray *imagesArray = [results objectForKey:@"media"];
		[self.images addObjectsFromArray:imagesArray];
		
		//NSLog(@"IMAGES:%@", self.images);
		
		[self userUploadsRequestFinished];
    }
	
	// hide loading
	[self hideLoading];
    
    [imagesFetcher release];
    imagesFetcher = nil;
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
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFeedResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedFeedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND MEDIA:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        imagesLoaded = YES;
		
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
    
    [imagesFetcher release];
    imagesFetcher = nil;
}


- (IBAction)loadMoreImages {
	
	[self showLoading];
	
	refresh = NO;
	
	switch (self.feedMode) {
			
		case FeedModeFeed:
			[self initFeedAPI];
			break;
			
		case FeedModeCity:
			[self initFindMediaAPI];
			break;
			
		default:
			break;
	}
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)removeThumbnails {
	
	for (GridImage *gImage in self.imagesView.subviews) {
		
		[gImage removeFromSuperview];
	}
}


- (void)refreshButtonClicked:(id)sender {
	
	if (!loading) {
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		[self removeThumbnails];
		
		// Clear images array
		[self.images removeAllObjects];
		
		switch (self.feedMode) {
				
			case FeedModeFeed:
				[self initFeedAPI];
				break;
				
			case FeedModeCity:
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
} 


- (NSString *)getUsersDefaultCity {

	// In time this should be a property that will be saved in NSUserDefaults.
	NSString *defaultCity = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultCityKey];
	
	return defaultCity;
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
	}
	
	NSLog(@"PHOTOS:\n%@", self.photos);
}


@end
