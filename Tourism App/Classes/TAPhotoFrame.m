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

#define MAIN_WIDTH 301
#define MAIN_HEIGHT 301
#define CONTAINER_START_POINT -349.0

@implementation TAPhotoFrame

@synthesize imageView, progressView, urlString, delegate, avatarView, container;
@synthesize containerView, actionsScrollView, actionsView, containerScroll;
@synthesize imageID;


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
		
		
		// SCROLL VIEW
		CGRect svFrame = CGRectMake(6.0, 0.0, 290.0, 349.0);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor yellowColor]];
		[sv setContentSize:CGSizeMake(1000.0, 349.0)];
		self.actionsScrollView = sv;
		[sv release];
		
		[self.container addSubview:self.actionsScrollView];
		[self.actionsScrollView release];
		

		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(9.0, 9.0, 272.0, 330.0);
		UIScrollView *av = [[UIScrollView alloc] initWithFrame:avFrame];
		[av setBackgroundColor:[UIColor blueColor]];
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
		CGRect btnFrame = CGRectMake(((cFrame.size.width/2)-40.0), 349.0, 80.0, 40.0);
		TAPullButton *pullBtn = [[TAPullButton alloc] initWithFrame:btnFrame];
		[pullBtn setFrame:btnFrame];
		[pullBtn setBackgroundColor:[UIColor cyanColor]];
		[pullBtn setDelegate:self];
		
		[self.container addSubview:pullBtn];
		[pullBtn release];
		
		
		// IMAGE URL
		self.urlString = imageURLString;
		
		
		// CAPTION
		CGFloat labelYPos = iViewFrame.origin.y + iViewFrame.size.height + 5.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, labelYPos, MAIN_WIDTH, 35.0)];
		[captionLabel setText:caption];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
		[self.container addSubview:captionLabel];
		[captionLabel release];
		
		
		// USERNAME BUTTON
		CGFloat usernameYPos = iViewFrame.origin.y + iViewFrame.size.height + 5.0 + 35.0;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(44.0, usernameYPos, 195.0, 25.0)];
		[btn setTitle:username forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
		[self.container addSubview:btn];
		
		
		// Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, usernameYPos, 15.0, 15.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self.container addSubview:self.avatarView];
		[self.avatarView release];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
	}
	
	return self;
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
	
	if (pullingUpward) { 
	
		if (yPos >= -5.0) {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = CONTAINER_START_POINT;
			
			[UIView animateWithDuration:0.5 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
				
			}];
		}
		
		else [self.delegate enableScroll];
	}
	
	else {
		
		if (yPos >= 0.0) {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = 0.0;
			
			[UIView animateWithDuration:0.25 animations:^{
				
				self.containerView.frame = newFrame;        
				
			} completion:^(BOOL finished) {
				
				[self.delegate enableScroll];
			}];
		}
		
		else [self.delegate enableScroll];
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
	
	CGFloat xPos = 0.0;
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
	[recommendBtn addTarget:self action:@selector(vouchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];				
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



#pragma ACTIONS

- (void)usernameClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate usernameButtonClicked];
}


- (void)loveButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveButtonTapped:self.imageID];
}


- (void)vouchButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate vouchButtonTapped:self.imageID];
}

@end
