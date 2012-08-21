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


#pragma MY-METHODS

- (IBAction)loadMoreButtonClicked:(id)sender {
	
	[self.loadMoreButton setEnabled:NO];
	
	/*
	if (self.collectionMode == CollectionModeLikedAndUser) [self callUserImagesAndLovedImagesAPI];
	else if (self.collectionMode == CollectionModeLiked) [self fetchLovedImages];	
	else [self fetchUserImages];
	*/
	
	[self fetchUserImages];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.imagesView.frame.size.width;
	CGFloat imageWidth = 75.0;
	CGFloat imageHeight = 75.0;
	CGFloat imagePadding = 4.0;
	CGFloat bottomPadding = imagePadding;
	
	CGFloat maxXPos = gridWidth - imageWidth;

	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add
	NSInteger numberOfRows = [self.images count]/4;
	
	// How many images have already been added to the imagesView view?
	NSInteger subviewsCount = [self.imagesView.subviews count];
	
	// If images have previously been added, calculate where to 
	// start placing the next batch of images
	if (subviewsCount > 0) {
		
		NSInteger rowCount = subviewsCount/4;
		NSInteger leftOver = subviewsCount%4;

		// Calculate starting xPos & yPos
		xPos = (leftOver * (imageWidth + imagePadding));
		yPos = (rowCount * (imageHeight + bottomPadding));
	}
	
	for (int i = 0; i < numberOfRows; i++) {
		
		// Retrieve Image object from array
		NSDictionary *image = [self.images objectAtIndex:i];
		NSString *thumbURL = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [image objectForKey:@"thumbnail"]];
		
		// Create GridImage, set its Tag and Delegate, and add it 
		// to the imagesView
		CGRect newFrame = CGRectMake(xPos, yPos, imageWidth, imageHeight);
		GridImage *gridImage = [[GridImage alloc] initWithFrame:newFrame imageURL:thumbURL];
		[gridImage setTag:(IMAGE_VIEW_TAG + i)];
		[gridImage setDelegate:self];
		[self.imagesView addSubview:gridImage];
		[gridImage release];
		
		// Update xPos & yPos for new image
		xPos += (imageWidth + imagePadding);
		
		if (xPos > maxXPos) {
			
			xPos = startXPos;
			yPos += (imageHeight + bottomPadding);
		}
	}
	
	// Update the scroll view's content height
	CGRect imagesViewFrame = self.imagesView.frame;
	CGRect loadMoreFrame = self.loadMoreButton.frame;
	CGFloat gridRowsHeight = (rowCount * imageHeight) + (bottomPadding * rowCount);
	CGFloat sViewContentHeight = imagesViewFrame.origin.y + gridRowsHeight  + loadMoreFrame.size.height + bottomPadding;
	CGFloat buttonYPos = imagesViewFrame.origin.y + gridRowsHeight;
	
	// Set image view frame height
	imagesViewFrame.size.height = gridRowsHeight;
	[self.imagesView setFrame:imagesViewFrame];
	
	// POSITION LOAD MORE BUTTON
	loadMoreFrame.origin.y = buttonYPos; 
	[self.loadMoreButton setFrame:loadMoreFrame];
	
	[self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, sViewContentHeight)];
}


- (void)fetchUserImages {
	
	fetchedUserImages = NO;
	
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
}


@end
