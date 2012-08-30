//
//  TAGuideDetailsVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAGuideDetailsVC.h"
#import "TAAppDelegate.h"
#import "JSONFetcher.h"
#import "SBJson.h"
#import "SVProgressHUD.h"
#import "GridImage.h"
#import "TAProfileVC.h"
#import "TAImageDetailsVC.h"
#import "TAMapVC.h"

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 75.0
#define GRID_IMAGE_HEIGHT 75.0
#define IMAGE_PADDING 4.0


@interface TAGuideDetailsVC ()

@end

@implementation TAGuideDetailsVC

@synthesize guideMode, images, guideID, gridScrollView, guideData;
@synthesize guideThumb, titleLabel, authorBtn, imagesView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	// FOR NOW: Add an "save" button to the top-right of the nav bar
	// if this is a guide NOT created by the logged-in user
	if (self.guideMode == GuideModeViewing) {
		
		UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"follow" style:UIBarButtonItemStyleDone target:self action:@selector(followGuide:)];
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
	
	self.guideID = nil;
	self.images = nil;
	self.guideData = nil;
	
    [imagesView release];
    self.imagesView = nil;
    [authorBtn release];
    self.authorBtn = nil;
    [titleLabel release];
    self.titleLabel = nil;
    [guideThumb release];
    self.guideThumb = nil;
	
	[gridScrollView release];
	self.gridScrollView = nil;
	
	[authorBtn release];
	authorBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[guideData release];
	[guideID release];
	[images release];
    [imagesView release];
    [authorBtn release];
    [titleLabel release];
    [guideThumb release];
	[gridScrollView release];
	[authorBtn release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	
	if (!guideLoaded && !loading) {
			
		// Show loading animation
		[self showLoading];
		
		// Fetch the guide data
		[self getGuide];
		
		[self initIsLovedAPI];
	}
}


#pragma UIActionSheetDelegate methods 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	// Love/Unlove
	if (buttonIndex == 0) {
	
		if (isLoved) [self initUnloveAPI];
		
		else [self initLoveAPI];
	}
	
	// View on map
	else if (buttonIndex == 1) { 
	
		TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
		[mapVC setMapMode:MapModeMultiple];
		[mapVC setPhotos:self.images];
		
		[self.navigationController pushViewController:mapVC animated:YES];
		[mapVC release];
	}
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
	
	NSDictionary *image = [self.images objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	// Push the Image Details VC onto the stack
	TAImageDetailsVC *imageDetailsVC = [[TAImageDetailsVC alloc] initWithNibName:@"TAImageDetailsVC" bundle:nil];
	[imageDetailsVC setImageCode:[image objectForKey:@"code"]];
	
	[self.navigationController pushViewController:imageDetailsVC animated:YES];
	[imageDetailsVC release];
}


#pragma MY-METHODS

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


- (void)getGuide {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&guideID=%@&token=%@", 
							[self appDelegate].loggedInUsername, [self guideID], [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Guide"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	guideFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedGetGuideResponse:)];
	[guideFetcher start];
}


// Example fetcher response handling
- (void)receivedGetGuideResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == guideFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSLog(@"PRINTING GET GUIDE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			self.guideData = [results objectForKey:@"guide"];
			
			// Build an array from the dictionary for easy access to each entry
			NSMutableArray *imagesArray = [[self.guideData  objectForKey:@"images"] mutableCopy];
			self.images = imagesArray;
			[imagesArray release];
			
			//NSLog(@"self.images:%@", self.images);
		}
		
		[jsonString release];
    }
	
	// Update UI elements
	[self updateUIElements];
	
	// Create the grid of images using the results
	[self updateImageGrid];
	
	// hide loading
	[self hideLoading];
    
    [guideFetcher release];
    guideFetcher = nil;
}


- (void)followGuide:(id)sender {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&guideID=%@&token=%@", [self appDelegate].loggedInUsername, [self guideID], [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FollowGuide"];	
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	guideFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedFollowGuideResponse:)];
	[guideFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowGuideResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == guideFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FOLLOW GUIDE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSInteger statusCode = [theJSONFetcher statusCode];
	
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			UIAlertView *response = [[UIAlertView alloc] initWithTitle:@"Hooray!" message:@"You have successfully saved this guide" delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil, nil];
			[response show];
			[response release];
		}
		
		[jsonString release];
    }
    
    [guideFetcher release];
    guideFetcher = nil;
}


- (void)updateUIElements {

	// Guide title
	[self.titleLabel setText:[self.guideData objectForKey:@"title"]];
	
	// Author label
	NSDictionary *userDict = [self.guideData objectForKey:@"author"];
	[self.authorBtn setTitle:[NSString stringWithFormat:@"by %@", [userDict objectForKey:@"username"]] forState:UIControlStateNormal];
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (IBAction)authorButtonTapped:(id)sender {
		
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	
	NSDictionary *userDict = [self.guideData objectForKey:@"author"];
	[profileVC setUsername:[userDict objectForKey:@"username"]];
	
	[self.navigationController pushViewController:profileVC animated:YES];
	[profileVC release];
}


- (void)initIsLovedAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&type=guide", [self appDelegate].loggedInUsername, self.guideID];	
	
	//username=fuzzyhead&code=nulprg&type=guide
	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"isLoved"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	isLovedFetcher = [[JSONFetcher alloc] initWithURLRequest:request
													receiver:self action:@selector(receivedIsLovedResponse:)];
	[isLovedFetcher start];
}


// Example fetcher response handling
- (void)receivedIsLovedResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
	NSAssert(aFetcher == isLovedFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"loved"] isEqualToString:@"true"]) isLoved = YES;
		
		NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	// Loved status
	[self updateLovedStatus];
	
	[isLovedFetcher release];
	isLovedFetcher = nil;
    
}


/*	This function is called once an isLovedResponse is received from
 the API. It uses the value of the lovesImage iVar to then set 
 the title of loveButton button. The loveButton is then enable for interaction */
- (void)updateLovedStatus {
	
	/*
	NSString *status = [NSString stringWithFormat:@"%@", ((isLoved) ? @"loved" : @"love")];
	
	// Update love button title
	[self.loveBtn setTitle:status forState:UIControlStateNormal];
	
	// update the background colour of the button
	UIColor *newColor;
	if (isLoved) newColor = [UIColor redColor];
	else newColor = [UIColor lightGrayColor];
	
	[self.loveBtn setBackgroundColor:newColor];
	
	// Re-enable the button
	[self.loveBtn setEnabled:YES];
	*/
}


- (IBAction)optionsButtonTapped:(id)sender {
	
	//@"Share on Twitter", @"Vouch"
	
	NSString *loveStatus = ((isLoved) ? @"Unlove" : @"Love");
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose an option" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:loveStatus, @"View on map", nil];
	
	[actionSheet showInView:[self view]];
	[actionSheet showFromTabBar:self.parentViewController.tabBarController.tabBar];
    [actionSheet release];
}


- (void)initLoveAPI {
		
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@&type=guide", [self appDelegate].loggedInUsername, self.guideID, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"Love"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedLoveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedLoveResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	// The "Love" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isLoved = YES;
		
		[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	[loveFetcher release];
	loveFetcher = nil;
    
}


- (void)initUnloveAPI {
		
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@&type=guide", [self appDelegate].loggedInUsername, self.guideID, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"UnLove"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedUnloveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedUnloveResponse:(HTTPFetcher *)aFetcher {
    
	JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
		
		[jsonString release];
	}
	
	// The "UnLove" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isLoved = NO;
		
		[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
	[loveFetcher release];
	loveFetcher = nil;
    
}



@end
