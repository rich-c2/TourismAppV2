//
//  TAImageDetailsVC.m
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAImageDetailsVC.h"
#import "TAAppDelegate.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "SVProgressHUD.h"
#import "StringHelper.h"
#import "ImageManager.h"
#import "TASimpleListVC.h"
#import "TAGuidesListVC.h"

@interface TAImageDetailsVC ()

@end

@implementation TAImageDetailsVC

@synthesize scrollView, progressIndicator, avatar, imageCode;
@synthesize usernameBtn, subtitle, mainPhoto, imageData, avatarURL, selectedURL;
@synthesize captionLabel, loveBtn, mapBtn, commentBtn, lovesCountBtn;

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
	
	// FOR NOW: Add an "add" button to the top-right of the nav bar
	// to let the user add to an existing guide
	UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithTitle:@"add" style:UIBarButtonItemStyleDone target:self action:@selector(addPhotoToGuide:)];
	buttonItem.target = self;
	self.navigationItem.rightBarButtonItem = buttonItem;
	[buttonItem release];
	
	
	// Set the initial UI elements using
	// the image metadata that we already have
	[self setUIElements];
	
	// Scroll view
	CGSize newSize = CGSizeMake(self.scrollView.frame.size.width, self.loveBtn.frame.origin.y + self.loveBtn.frame.size.height + 10.0);
	[self.scrollView setContentSize:newSize];
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate
{
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)viewDidUnload {
	
	[lovesCountBtn release];
	self.lovesCountBtn = nil;
	
	[avatarURL release];
	self.avatarURL = nil;
	
	[selectedURL release];
	self.selectedURL = nil;
	
	[imageData release];
	self.imageData = nil;
	
	[imageCode release];
	self.imageCode = nil;
	
    [scrollView release];
    scrollView = nil;
	
    [avatar release];
    avatar = nil;
	
    [mainPhoto release];
    mainPhoto = nil;
	
    [usernameBtn release];
    usernameBtn = nil;
	
    [commentBtn release];
    commentBtn = nil;
	
    [mapBtn release];
    mapBtn = nil;
	
    [loveBtn release];
    loveBtn = nil;
	
    [progressIndicator release];
    progressIndicator = nil;
	
    [subtitle release];
    subtitle = nil;
	
	[lovesCountBtn release];
	lovesCountBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[selectedURL release];
	[avatarURL release];
	[imageData release];
	[imageCode release];
    [scrollView release];
    [avatar release];
    [mainPhoto release];
    [usernameBtn release];
    [commentBtn release];
    [mapBtn release];
    [loveBtn release];
    [progressIndicator release];
    [subtitle release];
	[lovesCountBtn release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	if (!loading && !imageLoaded) {
	
		[self initMediaAPI];
	}
	
	[super viewWillAppear:animated];
}


#pragma MY-METHODS

- (void)setUIElements {

	NSArray *imageKeys = [self.imageData allKeys];
	
	// AVATAR & USERNAME
	if ([imageKeys containsObject:@"user"]) {
		
		NSDictionary *userDict = [self.imageData objectForKey:@"user"];
		
		NSString *avatarURLString = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [userDict objectForKey:@"avatar"]];
		[self initAvatarImage:avatarURLString];
		
		[self.usernameBtn setTitle:[userDict objectForKey:@"username"] forState:UIControlStateNormal];
	}
	

	// LOVES COUNT	
	if ([imageKeys containsObject:@"count"]) { 
		
		NSDictionary *countDict = [self.imageData objectForKey:@"count"];
		NSInteger lovesCount = [[countDict objectForKey:@"loves"] intValue];
		
		NSString *lovesText;
		if (lovesCount == 1) lovesText = [NSString stringWithFormat:@"%i love", lovesCount];
		else lovesText = [NSString stringWithFormat:@"%i loves", lovesCount];
		
		[self.lovesCountBtn setTitle:[NSString stringWithFormat:lovesText] forState:UIControlStateNormal];
	}
	
	
	// CAPTION	
	if ([self.imageData objectForKey:@"caption"]) { 
		
		[self.captionLabel setText:[self.imageData objectForKey:@"caption"]];
	}
	
	
	// CITY/TAG
	if ([self.imageData objectForKey:@"city"] && [self.imageData objectForKey:@"tag"]) { 
		
		NSString *city = [self.imageData objectForKey:@"city"];
		NSString *tag = [self.imageData objectForKey:@"tag"];
		
		[self.subtitle setTitle:[NSString stringWithFormat:@"%@/%@", city, tag] forState:UIControlStateNormal];
	}
	
	// MAIN PHOTO
	if ([imageKeys containsObject:@"paths"]) {
		
		NSDictionary *pathsDict = [self.imageData objectForKey:@"paths"];
		[self initImage:[NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS, [pathsDict objectForKey:@"zoom"]]];
	}
}


- (void)initMediaAPI {
	
	NSString *postString = [NSString stringWithFormat:@"code=%@", self.imageCode];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"media"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	mediaFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												receiver:self action:@selector(receivedMediaResponse:)];
	[mediaFetcher start];
}


// Example fetcher response handling
- (void)receivedMediaResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
	
	NSAssert(aFetcher == mediaFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING RECOMMENDATIONS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.imageData = [results objectForKey:@"media"];
		
		NSLog(@"imageData:%@", self.imageData);
		
		[jsonString release];
	}
	
	// Set the UI elements with the new data
	[self setUIElements];
	
	// Stop the loading animation
	[self hideLoading];
	
	[mediaFetcher release];
	mediaFetcher = nil;
}


- (void)showLoading {
	
	[SVProgressHUD showInView:self.view status:nil networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.selectedURL isEqual:url]) {
		
		NSLog(@"MAIN IMAGE LOADED:%@", [url description]);
		
		// Hide progress indicator
		[self.progressIndicator setHidden:YES];
		
		[self.mainPhoto setImage:image];
	}

	else if ([self.avatarURL isEqual:url]) {
		
		NSLog(@"AVATAR IMAGE LOADED:%@", [url description]);

		[self.avatar setImage:image];
	}
}


- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatar.image) {
		
		NSLog(@"LOADING AVATAR IMAGE:%@", avatarURLString);
		
		self.avatarURL = [avatarURLString convertToURL];
		
		UIImage *img = [ImageManager loadImage:self.avatarURL progressIndicator:nil];
		if (img) [self.avatar setImage:img];
    }
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.selectedURL = [urlString convertToURL];
		
		NSLog(@"LOADING MAIN IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:self.selectedURL progressIndicator:self.progressIndicator];
		if (img) {
			
			// Hide progress indicator
			[self.progressIndicator setHidden:YES];
			[self.mainPhoto setImage:img];
		}
    }
}


- (IBAction)lovesCountButtonTapped:(id)sender {
	
	TASimpleListVC *listVC = [[TASimpleListVC alloc] initWithNibName:@"TASimpleListVC" bundle:nil];
	[listVC setImageCode:self.imageCode];
	[self.navigationController pushViewController:listVC animated:YES];
	[listVC release];
}


- (void)addPhotoToGuide:(id)sender {
	
	NSDictionary *userDict = [self.imageData objectForKey:@"user"];

	TAGuidesListVC *guidesVC = [[TAGuidesListVC alloc] initWithNibName:@"TAGuidesListVC" bundle:nil];
	[guidesVC setUsername:[userDict objectForKey:@"username"]];
	[guidesVC setGuidesMode:GuidesModeAddTo];
	[guidesVC setSelectedTag:[self.imageData objectForKey:@"tag"]];
	[guidesVC setSelectedCity:[self.imageData objectForKey:@"city"]];
	
	[self.navigationController pushViewController:guidesVC animated:YES];
	[guidesVC release];
}


@end
