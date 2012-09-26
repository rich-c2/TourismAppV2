//
//  TAPhotoFrame.m
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAPhotoFrame.h"
#import "UIImageView+AFNetworking.h"
#import "ImageManager.h"
#import "TACommentView.h"
#import "TAAppDelegate.h"
#import "SBJson.h"
#import "JSONFetcher.h"
#import "TAGuideButton.h"
#import "TACreateGuideForm.h"

#define MAIN_WIDTH 301
#define MAIN_HEIGHT 301
#define CONTAINER_START_POINT -349.0
#define SCROLL_COLUMN_WIDTH 290
#define SCROLL_COLUMN_PADDING 10

#define INNER_VIEW_TAG 8888

@implementation TAPhotoFrame

@synthesize imageView, progressView, urlString, delegate, avatarView, container;
@synthesize containerView, actionsScrollView, actionsView, containerScroll;
@synthesize imageID, guides, selectedCity, selectedTagID, guidesView, newGuideView;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)_imageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL {

	self = [super initWithFrame:frame];
	
    if (self) {
		
		self.imageID = _imageID;
		
		
		/* 
			STRUCTURE
		 
			First layer is a UIView that acts as
			the container of all the content within in 'Photo frame'
			Second layer is another UIView, followed by a scroll view
			(ActionsScrollView) which will contain all the content
			related to actions.
		 */
		
		CGRect cvFrame = CGRectMake(9.0, CONTAINER_START_POINT, MAIN_WIDTH, 708.0);
		UIView *cv = [[UIView alloc] initWithFrame:cvFrame];
		[cv setBackgroundColor:[UIColor clearColor]];
		self.containerView = cv;
		[cv release];
		
		[self addSubview:self.containerView];
		[self.containerView release];
		
		CGRect cFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 708.0);
		UIView *c = [[UIView alloc] initWithFrame:cFrame];
		[c setBackgroundColor:[UIColor clearColor]];
		self.container = c;
		[c release];
		
		[self.containerView addSubview:self.container];
		[self.container release];
		
		
		// ACTIONS AREA BG
		CGRect bgFrame = CGRectMake(6.0, 0.0, SCROLL_COLUMN_WIDTH, 350.0);
		UIImageView *bgImage = [[UIImageView alloc] initWithFrame:bgFrame];
		[bgImage setImage:[UIImage imageNamed:@"photo-actions-shadow-bg.png"]];		
		[self.container addSubview:bgImage];
		[bgImage release];
		
		
		// SCROLL VIEW
		CGRect svFrame = CGRectMake(6.0, 0.0, SCROLL_COLUMN_WIDTH, 349.0);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setPagingEnabled:YES];
		self.actionsScrollView = sv;
		[sv release];
		
		[self.container addSubview:self.actionsScrollView];
		[self.actionsScrollView release];
		

		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(0.0, 10.0, SCROLL_COLUMN_WIDTH, 330.0);
		UIScrollView *av = [[UIScrollView alloc] initWithFrame:avFrame];
		self.actionsView = av;
		[av release];
		
		[self.actionsScrollView addSubview:self.actionsView];
		[self.actionsView release];
		
		
		[self populateActionsView];
		
		
		/*	
			IMAGE DISPLAY 
		 
			UIImageView for the polaroid image artwork, with 
			a TAPhotoView on top of that as our placeholder
			for the actual image that is being downloaded
			to be placed into.
		*/
		
		CGRect polaroidFrame = CGRectMake(0.0, 359.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
		[self.container addSubview:polaroidBG];
		[polaroidBG release];
		
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(10.0, 369.0, 281.0, 281.0);
		TAPhotoView *iView = [[TAPhotoView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		[iView release];
		
		[self.container addSubview:self.imageView];
		[self.imageView release];
		
		
		/*
			PROGRESS INDICATOR
		 
			Progress Indicator is a property as it needs
			to be updated regularly as the main image download
			is progressing.
		*/
		CGRect mainViewFrame = self.imageView.frame;
		CGFloat progressXPos = (mainViewFrame.size.width/2.0) - 75.0;
		CGFloat progressYPos = mainViewFrame.origin.y + ((mainViewFrame.size.height/2.0) - 4.0);
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self.container addSubview:self.progressView];
		[self.progressView release];
		
		
		
		// PULL BUTTON
		CGRect btnFrame = CGRectMake(((cFrame.size.width/2)-39.0), 346.0, 78.0, 58.0);
		TAPullButton *pullBtn = [[TAPullButton alloc] initWithFrame:btnFrame];
		[pullBtn setFrame:btnFrame];
		[pullBtn setDelegate:self];
		
		[self.container addSubview:pullBtn];
		[pullBtn release];
		
		
		// IMAGE URL
		self.urlString = imageURLString;
		
		
		// CAPTION
		CGFloat labelYPos = iViewFrame.origin.y + iViewFrame.size.height + 10.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, labelYPos, MAIN_WIDTH, 18.0)];
		[captionLabel setText:caption];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
		[self.container addSubview:captionLabel];
		[captionLabel release];
		
		
		// USERNAME BUTTON
		CGFloat usernameYPos = iViewFrame.origin.y + iViewFrame.size.height + 10.0 + 18.0;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(28.0, usernameYPos, 195.0, 25.0)];
		[btn setTitle:username forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
		[self.container addSubview:btn];
		
		
		// Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, (usernameYPos+4), 15.0, 15.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self.container addSubview:self.avatarView];
		[self.avatarView release];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
	}
	
	return self;
}


#pragma mark - Private Methods
- (TAAppDelegate *)appDelegate {
	
    return (TAAppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma PullButtonDelegate methods 

- (void)buttonTouched {

	[self.delegate disableScroll];
	//NSLog(@"GOTCHA'");
}


- (void)buttonPulledDown:(CGFloat)shift {

	//NSLog(@"SHIFT:%f", shift);
	
	CGRect newFrame = self.containerView.frame;
	newFrame.origin.y = (newFrame.origin.y - shift);
	
	[self.containerView setFrame:newFrame];
}


- (void)buttonPulledToPoint:(CGFloat)yPos {

	CGRect newFrame = self.containerView.frame;
	newFrame.origin.y +=  (CONTAINER_START_POINT + yPos);
	
	[self.containerView setFrame:newFrame];
}


- (void)pullDownEnded:(CGFloat)lastYPos pullingUpward:(BOOL)pullingUpward {
	
	CGFloat yPos = (CONTAINER_START_POINT + lastYPos);
	
	NSLog(@"%@", ((pullingUpward) ? @"PULLING UP" : @"PULLING DOWN"));
	NSLog(@"LAST Y POS:%.2f", lastYPos);
	NSLog(@"Y POS:%.2f", yPos);
	
	if (pullingUpward) { 
	
		if (yPos >= -14.0) {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = CONTAINER_START_POINT;
			
			[UIView animateWithDuration:0.25 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
				
			}];
		}
		
		else {
		
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = 0.0;
			
			[UIView animateWithDuration:0.5 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
			}];
		} 
	}
	
	else {
		
		if (yPos >= 5.0) {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = 0.0;
			
			[UIView animateWithDuration:0.5 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
			}];
		}
		
		else {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = CONTAINER_START_POINT;
			
			[UIView animateWithDuration:0.25 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
			}];
		}
	}
}



#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

	if (pullEnabled) {
	
		NSLog(@"Y OFFSET:%f", scrollView.contentOffset.y);
	}	
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView { 

	if (pullEnabled) {
	
		
	}
}


- (void)populateActionsView {
	
	CGFloat xPos = SCROLL_COLUMN_PADDING;
	CGFloat yPos = 0.0;
	CGFloat buttonWidth = 272.0;
	CGFloat buttonHeight = 32.0;
	CGFloat buttonPadding = 3.0;

	// ADD TO GUIDE BUTTON
	CGRect addToGuideFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *addToGuideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[addToGuideBtn setFrame:addToGuideFrame];
	[addToGuideBtn setImage:[UIImage imageNamed:@"add-to-guide-button.png"] forState:UIControlStateNormal];
	[addToGuideBtn addTarget:self action:@selector(addToGuideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];	
	[self.actionsView addSubview:addToGuideBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// VIEW ON MAP BUTTON
	CGRect mapFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *viewOnMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[viewOnMapBtn setFrame:mapFrame];
	[viewOnMapBtn setImage:[UIImage imageNamed:@"view-on-map-button.png"] forState:UIControlStateNormal];
	[viewOnMapBtn addTarget:self action:@selector(viewOnMapButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[self.actionsView addSubview:viewOnMapBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// LOVE BUTTON
	CGRect loveFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[loveBtn setFrame:loveFrame];
	[loveBtn setImage:[UIImage imageNamed:@"love-photo-button.png"] forState:UIControlStateNormal];
	[loveBtn addTarget:self action:@selector(loveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];			
	[self.actionsView addSubview:loveBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// COMMENT BUTTON
	CGRect commentFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[commentBtn setFrame:commentFrame];
	[commentBtn setImage:[UIImage imageNamed:@"add-comment-button.png"] forState:UIControlStateNormal];
	[commentBtn addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.actionsView addSubview:commentBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// VOUCH BUTTON
	CGRect vouchFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *vouchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[vouchBtn setFrame:vouchFrame];
	[vouchBtn setImage:[UIImage imageNamed:@"vouch-button.png"] forState:UIControlStateNormal];
	[vouchBtn addTarget:self action:@selector(vouchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[self.actionsView addSubview:vouchBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// RECOMMEND BUTTON
	CGRect recommendFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[recommendBtn setFrame:recommendFrame];
	[recommendBtn setImage:[UIImage imageNamed:@"recommend-photo-button.png"] forState:UIControlStateNormal];
	[recommendBtn addTarget:self action:@selector(recommendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];				
	[self.actionsView addSubview:recommendBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// FLAG BUTTON
	CGRect flagFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *flagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[flagBtn setFrame:flagFrame];
	[flagBtn setImage:[UIImage imageNamed:@"flag-photo-button.png"] forState:UIControlStateNormal];
	[flagBtn addTarget:self action:@selector(flagButtonTapped:) forControlEvents:UIControlEventTouchUpInside];				
	[self.actionsView addSubview:flagBtn];
	
	
	yPos += (buttonHeight + buttonPadding);
	
	
	// TWEET BUTTON
	CGRect tweetFrame = CGRectMake(xPos, yPos, 136.0, buttonHeight);
	
	UIButton *tweetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[tweetBtn setBackgroundColor:[UIColor whiteColor]];
	[tweetBtn setFrame:tweetFrame];
	[tweetBtn setTitle:@"Tweet" forState:UIControlStateNormal];
	[tweetBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[tweetBtn addTarget:self action:@selector(tweetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[tweetBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
	[tweetBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
	[self.actionsView addSubview:tweetBtn];
	
	
	// EMAIL BUTTON
	CGRect emailFrame = CGRectMake((xPos + 136.0 + 4.0), yPos, 136.0, buttonHeight);
	
	UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[emailBtn setBackgroundColor:[UIColor whiteColor]];
	[emailBtn setFrame:emailFrame];
	[emailBtn setTitle:@"Email" forState:UIControlStateNormal];
	[emailBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[emailBtn addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[emailBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
	[emailBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
	[self.actionsView addSubview:emailBtn];
}


#pragma CreateGuideFormDelegate methods 

- (void)createGuide:(NSString *)title privateGuide:(BOOL)privateGuide {

	[self returnToActions];
	
	[self.delegate createGuideWithPhoto:self.imageID title:title isPrivate:privateGuide];
}


#pragma GuideButtonDelegate methods 

- (void)selectedGuide:(NSString *)guideID {

	[self returnToActions];
	
	[self.delegate addPhotoToSelectedGuide:guideID];
}


#pragma CommentViewDelegate methods 

- (void)commentReadyForSubmit:(NSString *)commentText {
	
	[self returnToActions];

	[self.delegate commentButtonTapped:self.imageID commentText:commentText];
}


#pragma MY METHODS 

- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatarView.image) {
		
		[self.avatarView setBackgroundColor:[UIColor grayColor]];
		
		// Start the image request/download
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURLString]] success:^(UIImage *requestedImage) {
            self.avatarView.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}


- (void)initImage {
	
	if (self.urlString && !self.imageView.image) {
		
		UIImage *image = [ImageManager loadImage:[NSURL URLWithString:self.urlString] progressIndicator:self.progressView];
		
		if (image) {
			
			// Hide progress indicator
			[self.progressView setHidden:YES];
			
			self.imageView.image = image;
		}
    }
}


- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url {
	
    if ([[NSURL URLWithString:self.urlString] isEqual:_url]) {
		
		// Hide progress indicator
		[self.progressView setHidden:YES];
		
		//[self.loadingSpinner stopAnimating];
        self.imageView.image = image;
    }
}


- (void)returnToActions {
	
	// Reset the contentSize to the minimum width
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width = self.actionsScrollView.frame.size.width;
	self.actionsScrollView.contentSize = newSize;
	
	// Disable the actions scroll view from 
	// being interacted with
	self.actionsScrollView.userInteractionEnabled = NO;
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(0.0, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
		
		self.actionsScrollView.userInteractionEnabled = YES;
		
		UIView *innerView = [self.actionsScrollView viewWithTag:INNER_VIEW_TAG];
		[innerView removeFromSuperview];
		
		UIView *innerView2 = [self.actionsScrollView viewWithTag:(INNER_VIEW_TAG+1)];
		if (innerView2) [innerView removeFromSuperview];

	}];
}


#pragma ACTIONS

- (void)usernameClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate usernameButtonClicked];
}


- (void)viewOnMapButtonTapped:(id)sender {

	// not implemented
}


- (void)tweetButtonTapped:(id)sender {

	[self.delegate tweetButtonTapped:self.imageID];
}


- (void)emailButtonTapped:(id)sender {
	
	[self.delegate emailButtonTapped:self.imageID];
}


- (void)recommendButtonTapped:(id)sender {

// not implemented
}


- (void)loveButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveButtonTapped:self.imageID];
}


- (void)vouchButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate vouchButtonTapped:self.imageID];
}


- (void)flagButtonTapped:(id)sender {

	// pass info on to delegate
	[self.delegate flagButtonTapped:self.imageID];
}


- (void)commentButtonTapped:(id)sender {
	
	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	

	CGRect commentFrame = CGRectMake(SCROLL_COLUMN_WIDTH, 0.0, MAIN_WIDTH, 330.0);
	TACommentView *commentView = [[TACommentView alloc] initWithFrame:commentFrame];
	[commentView setDelegate:self];
	[commentView setTag:INNER_VIEW_TAG];
	
	[self.actionsScrollView addSubview:commentView];
	[commentView release];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(SCROLL_COLUMN_WIDTH, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
		
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)addToGuideButtonTapped:(id)sender {
	
	// Find the existing Guides that this
	// photo can be added to be calling the
	// "FindGuides" API
	[self initFindGuidesAPI];
}


- (void)initFindGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%@&private=0&token=%@", [self appDelegate].loggedInUsername, [self.selectedTagID intValue], self.selectedCity, 0, @"4", [[self appDelegate] sessionToken]];
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = [NSString stringWithString:@"FindGuides"];
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	guidesFetcher = [[JSONFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindGuidesResponse:)];
	[guidesFetcher start];
}	


// Example fetcher response handling
- (void)receivedFindGuidesResponse:(HTTPFetcher *)aFetcher {
    
    JSONFetcher *theJSONFetcher = (JSONFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING GET GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString JSONValue];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
		
		[jsonString release];
    }
	
	// Reload the table
	[self goToGuidesView];
    
    [guidesFetcher release];
    guidesFetcher = nil;
}


- (void)goToGuidesView {

	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect guidesFrame = CGRectMake(SCROLL_COLUMN_WIDTH, 0.0, MAIN_WIDTH, 330.0);
	
	UIView *gv = [[UIView alloc] initWithFrame:guidesFrame];
	[gv setTag:INNER_VIEW_TAG];
	
	self.guidesView = gv;
	[gv release];
	
	[self.actionsScrollView addSubview:self.guidesView];
	[self.guidesView release];
	
	[self createGuideButtons];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(SCROLL_COLUMN_WIDTH, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
		
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)createGuideButtons {
	
	CGFloat xPos = SCROLL_COLUMN_PADDING;
	CGFloat yPos = 10.0;
	CGFloat buttonWidth = 272.0;
	CGFloat buttonHeight = 45.0;
	CGFloat buttonPadding = 3.0;
	
	for (NSMutableDictionary *guide in self.guides) {
		
		// ADD TO GUIDE BUTTON
		CGRect guideBtnFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
		
		TAGuideButton *guideBtn = [[TAGuideButton alloc] initWithFrame:guideBtnFrame title:[guide objectForKey:@"title"] loves:[guide objectForKey:@"loves"]];
		[guideBtn setGuideID:[guide objectForKey:@"guideID"]];
		[guideBtn setDelegate:self];
		
		[self.guidesView addSubview:guideBtn];
		[guideBtn release];
		
		yPos += (buttonHeight + buttonPadding);
	}
	
	
	// 'CREATE A NEW GUIDE' BUTTON
	CGRect newFrame = CGRectMake(xPos, yPos, buttonWidth, 37.0);
	UIButton *addToNewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[addToNewBtn setFrame:newFrame];
	[addToNewBtn setImage:[UIImage imageNamed:@"create-new-guide-button.png"] forState:UIControlStateNormal];
	[addToNewBtn addTarget:self action:@selector(goToNewGuide:) forControlEvents:UIControlEventTouchUpInside];
	[addToNewBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
	[self.guidesView addSubview:addToNewBtn];
}


- (void)guideButtonTapped:(id)sender {

	NSLog(@"HEY");
}


- (void)goToNewGuide:(id)sender {
	
	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect guidesFrame = CGRectMake((SCROLL_COLUMN_WIDTH*2), 0.0, MAIN_WIDTH, 330.0);
	
	TACreateGuideForm *gv = [[TACreateGuideForm alloc] initWithFrame:guidesFrame];
	[gv setTag:(INNER_VIEW_TAG+1)];
	[gv setDelegate:self];
	
	self.newGuideView = gv;
	[gv release];
	
	[self.actionsScrollView addSubview:self.newGuideView];
	[self.newGuideView release];
	
	//[self initNewGuideView];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(guidesFrame.origin.x, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
		
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)initNewGuideView {
	
	CGFloat xPos = 8.0;
	CGFloat yPos = 10.0;
	CGFloat bgWidth = 274.0;
	CGFloat bgHeight = 45.0;
	CGFloat padding = 1.0;

	// Add form field bgs
	UIImage *fieldBGImage = [UIImage imageNamed:@"form-field-bg-small.png"];
	
	
	for (int i = 0; i < 4; i++) {
	
		CGRect fieldFrame1 = CGRectMake(xPos, yPos, bgWidth, bgHeight);
		UIImageView *fieldViewBG = [[UIImageView alloc] initWithFrame:fieldFrame1];
		[fieldViewBG setImage:fieldBGImage];
		
		[self.newGuideView addSubview:fieldViewBG];
		[fieldViewBG release];
		
		yPos += (bgHeight + padding);
	}
}




@end
