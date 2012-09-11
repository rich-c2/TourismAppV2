//
//  TAImageGridVC.m
//  Tourism App
//
//  Created by Richard Lee on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAImageGridVC.h"
#import "JSONFetcher.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "SBJson.h"
#import "TAAppDelegate.h"
#import "GridImage.h"
#import "Photo.h"
#import "TATimelineVC.h"
#import "TAExploreVC.h"
#import "TAMapVC.h"

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 75.0
#define GRID_IMAGE_HEIGHT 75.0
#define IMAGE_PADDING 4.0
#define MAIN_CONTENT_HEIGHT 367.0


@interface TAImageGridVC ()

@end

@implementation TAImageGridVC

@synthesize tagID, tag, city, resetButton, filterButton;
@synthesize imagesView, gridScrollView;
@synthesize masterArray, username, imagesMode, photos, filteredPhotos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// The fetch size for each API call
    fetchSize = 20;
	
	if (self.imagesMode == ImagesModeLikedPhotos || self.imagesMode == ImagesModeMyPhotos) {
	
		// view mode options
		UIBarButtonItem *filterButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"filter" style:UIBarButtonItemStyleDone target:self action:@selector(filterButtonTapped:)];
		filterButtonItem.target = self;
		
		self.filterButton = filterButtonItem;
		[filterButtonItem release];
		
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"reset" style:UIBarButtonItemStyleDone target:self action:@selector(resetPhotoFilters:)];
		buttonItem.target = self;
		
		self.resetButton = buttonItem;
		[buttonItem release];
	}
	
	if (self.imagesMode == ImagesModeCityTag) {
	
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"map" style:UIBarButtonItemStyleDone target:self action:@selector(viewImagesMap:)];
		buttonItem.target = self;
		
		self.navigationItem.rightBarButtonItem = buttonItem;
		[buttonItem release];
	}
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.tagID = nil; 
	self.tag = nil; 
	self.city = nil;
	
	self.resetButton = nil;
	self.filterButton = nil;
	
	self.filteredPhotos = nil;
	self.photos = nil;
	self.masterArray = nil;
	self.username = nil;
	
    [gridScrollView release];
    gridScrollView = nil;
    [imagesView release];
    imagesView = nil;
	
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[resetButton release];
	[filterButton release];
	
	[tagID release]; 
	[tag release]; 
	[city release];
	[photos release];
	[masterArray release];
	
	[username release];
	[filteredPhotos release];
    [gridScrollView release];
    [imagesView release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	if (!loading && !imagesLoaded) {
		
		// Init array
		if (!self.filteredPhotos) self.filteredPhotos = [NSMutableArray array];
		if (!self.photos) self.photos = [NSMutableArray array];
		if (!self.masterArray) self.masterArray = [NSMutableArray array];
		
		switch (self.imagesMode) {
				
			case ImagesModeMyPhotos:
				self.masterArray = self.photos;
				[self setupNavBar];
				[self initUploadsAPI];
				break;
				
			case ImagesModeLikedPhotos:
				self.masterArray = self.photos;
				[self setupNavBar];
				[self initLovedAPI];
				break;
				
			case ImagesModeCityTag:
				self.masterArray = self.photos;
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
}


#pragma ExploreDelegate methods 

- (void)finishedFilteringWithPhotos:(NSArray *)newPhotos {
	
	filterMode = YES;
	[self setupNavBar];

	NSMutableArray *mutablePhotos = [newPhotos mutableCopy];
	self.filteredPhotos = mutablePhotos;
	[mutablePhotos release];
	
	self.masterArray = self.filteredPhotos;
	
	
	
	[self refreshImageGrid];
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
	if (refresh && !loading) [self loadMoreImages];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
	NSLog(@"REFRESH IS:%@", ((refresh) ? @"YES" : @"NO"));
	
	refresh = NO;
}


#pragma GridImageDelegate methods 

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	Photo *photo = [self.masterArray objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	// Push the Image Details VC onto the stack
	TATimelineVC *timelineVC = [[TATimelineVC alloc] initWithNibName:@"TATimelineVC" bundle:nil];
	[timelineVC setPhotos:self.masterArray];
	[timelineVC setSelectedImageID:[photo photoID]];
	
	[self.navigationController pushViewController:timelineVC animated:YES];
	[timelineVC release];
}


#pragma MY-METHODS


- (void)initFindMediaAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%i&token=%@", [self appDelegate].loggedInUsername, [self.tagID intValue], self.city, imagesPageIndex, fetchSize, [[self appDelegate] sessionToken]];
	NSLog(@"jsonString:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindMedia"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
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
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
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
		
	// Make a new call to the Uploads API
	if (self.imagesMode == ImagesModeMyPhotos) [self initUploadsAPI];
	
	else if (self.imagesMode == ImagesModeCityTag) [self initFindMediaAPI];
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
	
	for (int i = subviewsCount; i < [self.masterArray count]; i++) {
		
		// Retrieve Photo object from array, and construct
		// a URL string for the thumbnail image
		Photo *photo = [self.masterArray objectAtIndex:i];
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


- (void)initUploadsAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", self.username, imagesPageIndex, fetchSize];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Uploads"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedUploadsResponse:)];
	[imagesFetcher start];
} 


// Example fetcher response handling
- (void)receivedUploadsResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	//NSLog(@"UPLOADS DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == imagesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
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
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
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


- (void)initLovedAPI {
	
	loading = YES;
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", [self appDelegate].loggedInUsername, imagesPageIndex, fetchSize];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Loved"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	imagesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedLovedResponse:)];
	[imagesFetcher start];
}


// Example fetcher response handling
- (void)receivedLovedResponse:(HTTPFetcher *)aFetcher {
    
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
		
		// Take the data from the API, convert it 
		// to Photos objects and store them in 
		// self.photos array
		[self updatePhotosArray:imagesArray];
		
		
		// Request is done. Now update the UI and 
		// the relevant iVars
		[self lovedImagesRequestFinished];
    }
    
    [imagesFetcher release];
    imagesFetcher = nil;
}


- (void)lovedImagesRequestFinished {
	
	// update the page index for 
	// the next batch
	imagesPageIndex++;
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)setupNavBar {
	
	if (!filterMode) self.navigationItem.rightBarButtonItem = self.filterButton;
	else self.navigationItem.rightBarButtonItem = self.resetButton;
	
}


- (void)filterButtonTapped:(id)sender {

	TAExploreVC *exploreVC = [[TAExploreVC alloc] initWithNibName:@"TAExploreVC" bundle:nil];
	[exploreVC setExploreMode:ExploreModeSubset];
	[exploreVC setPhotos:self.photos];
	[exploreVC setDelegate:self];

	[self.navigationController pushViewController:exploreVC animated:NO];
	[exploreVC release];
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
	 
	 
- (void)refreshImageGrid {
	
	[self showLoading];

	[self removeThumbnails];
	
	if (filterMode) {
	
		[self updateImageGrid];
		
		[self hideLoading];
	}
	
	else {
		
		// Reset page index and call the two
		// relevant APIs
		imagesPageIndex = 0;
		
		switch (self.imagesMode) {
				
			case ImagesModeMyPhotos:
				[self initUploadsAPI];
				break;
				
			case ImagesModeLikedPhotos:
				[self initLovedAPI];
				break;
				
			case ImagesModeCityTag:
				[self initFindMediaAPI];
				break;
				
			default:
				break;
		}
	}
}


- (void)resetPhotoFilters:(id)sender {
	
	filterMode = NO;

	[self showLoading];
	
	[self setupNavBar];
	
	[self removeThumbnails];
	
	self.masterArray = self.photos;
	
	[self.filteredPhotos removeAllObjects];
	
	[self updateImageGrid];
	
	[self hideLoading];
}
	 
	 
- (void)removeThumbnails {
 
	for (GridImage *gImage in self.imagesView.subviews) {
	 
		[gImage removeFromSuperview];
	}
}


- (void)viewImagesMap:(id)sender {

	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setMapMode:MapModeMultiple];
	[mapVC setPhotos:self.photos];
	
	[self.navigationController pushViewController:mapVC animated:YES];
	[mapVC release];
}
	 
	 
@end
