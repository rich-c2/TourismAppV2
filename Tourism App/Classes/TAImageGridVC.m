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

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 75.0
#define GRID_IMAGE_HEIGHT 75.0
#define IMAGE_PADDING 4.0


@interface TAImageGridVC ()

@end

@implementation TAImageGridVC

@synthesize imagesView, gridScrollView, loadMoreButton;
@synthesize images, username;

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
    fetchSize = 12;
	
	// Init array
	self.images = [NSMutableArray array];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.images = nil;
	self.username = nil;
	
    [gridScrollView release];
    gridScrollView = nil;
    [imagesView release];
    imagesView = nil;
    [loadMoreButton release];
    loadMoreButton = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[username release];
	[images release];
    [gridScrollView release];
    [imagesView release];
    [loadMoreButton release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	[self fetchUserImages];
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


#pragma GridImageDelegate methods 

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	/*
	NSDictionary *image = [self.images objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	ImageVC *imageVC = [[ImageVC alloc] initWithNibName:@"ImageVC" bundle:nil];
	[imageVC setSelectedImage:selectedImage];
	
	[self.navigationController pushViewController:imageVC animated:YES];
	[imageVC release];
	*/
}


#pragma MY-METHODS

- (IBAction)loadMoreButtonClicked:(id)sender {
	
	[self.loadMoreButton setEnabled:NO];
	
	/*
	if (self.collectionMode == CollectionModeLikedAndUser) [self callUserImagesAndLovedImagesAPI];
	else if (self.collectionMode == CollectionModeLiked) [self fetchLovedImages];	
	else [self fetchUserImages];
	*/
	
	// Make a new call to the Uploads API
	[self fetchUserImages];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.imagesView.frame.size.width;
	CGFloat bottomPadding = IMAGE_PADDING;
	
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;

	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add, and how many have already
	// been added previously
	NSInteger numberOfRows = [self.images count]/4;
	NSInteger subviewsCount = [self.imagesView.subviews count];
	
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
	
	for (int i = subviewsCount; i < [self.images count]; i++) {
		
		// Retrieve Image object from array, and construct
		// a URL string for the thumbnail image
		NSDictionary *image = [self.images objectAtIndex:i];
		NSDictionary *paths = [image objectForKey:@"paths"];
		NSString *thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [paths objectForKey:@"thumb"]];
		
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
			yPos += (GRID_IMAGE_HEIGHT + bottomPadding);
		}
	}
	
	// Updated number of how many rows there are
	NSInteger rowCount = [[self.imagesView subviews] count]/4;
	NSInteger leftOver = [[self.imagesView subviews] count]%4;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGRect imagesViewFrame = self.imagesView.frame;
	CGRect loadMoreFrame = self.loadMoreButton.frame;
	CGFloat gridRowsHeight = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	CGFloat sViewContentHeight = imagesViewFrame.origin.y + gridRowsHeight  + loadMoreFrame.size.height + bottomPadding;
	
	// Set image view frame height
	imagesViewFrame.size.height = gridRowsHeight;
	[self.imagesView setFrame:imagesViewFrame];
	
	// POSITION LOAD MORE BUTTON
	CGFloat buttonYPos = imagesViewFrame.origin.y + gridRowsHeight;
	loadMoreFrame.origin.y = buttonYPos; 
	[self.loadMoreButton setFrame:loadMoreFrame];
	
	// Adjust content height of the scroll view
	[self.gridScrollView setContentSize:CGSizeMake(self.gridScrollView.frame.size.width, sViewContentHeight)];
}


- (void)fetchUserImages {
	
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
	
	NSLog(@"DETAILS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
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
	
	// Re-enable the "load more" button
	[self.loadMoreButton setEnabled:YES];
	
	// Update the image grid
	[self updateImageGrid];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


@end
