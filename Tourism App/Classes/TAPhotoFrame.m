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

#define MAIN_IMAGE_WIDTH 280
#define MAIN_IMAGE_HEIGHT 280

@implementation TAPhotoFrame

@synthesize imageView, progressView, urlString, delegate, avatarView, container;
@synthesize containerView, actionsScrollView, actionsView, containerScroll;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString 
			caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(20.0, 0.0, MAIN_IMAGE_WIDTH, MAIN_IMAGE_HEIGHT);
		UIImageView *iView = [[UIImageView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		[iView release];
		
		[self addSubview:self.imageView];
		[self.imageView release];
		
		
		// AVATAR IMAGE VIEW
		CGFloat avatarYPos = MAIN_IMAGE_HEIGHT + 5.0 + 35.0;
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, avatarYPos, 30.0, 30.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self addSubview:self.avatarView];
		[self.avatarView release];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
		
		
		// PROGRESS INDICATOR
		CGRect mainViewFrame = self.frame;
		CGFloat progressXPos = (mainViewFrame.size.width/2.0) - 75.0;
		CGFloat progressYPos = (mainViewFrame.size.height/2.0) - 4.0;
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self addSubview:self.progressView];
		[self.progressView release];
		
		// IMAGE URL
		self.urlString = imageURLString;
		
		// CAPTION
		CGFloat labelYPos = MAIN_IMAGE_HEIGHT + 5.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, labelYPos, MAIN_IMAGE_WIDTH, 35.0)];
		[captionLabel setText:caption];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:captionLabel];
		[captionLabel release];
		
		// USERNAME BUTTON
		CGFloat usernameYPos = MAIN_IMAGE_HEIGHT + 5.0 + 35.0;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(44.0, usernameYPos, 195.0, 25.0)];
		[btn setTitle:username forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
		[self addSubview:btn];

    }
    return self;
}


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString {

	self = [super initWithFrame:frame];
	
    if (self) {
		
		// CONTAINER
		/*CGRect containerFrame = CGRectMake(15.0, 0.0, 290.0, 411.0);
		UIScrollView *cs = [[UIScrollView alloc] initWithFrame:containerFrame];
		[cs setBackgroundColor:[UIColor blackColor]];
		[cs setDelegate:self];
		self.containerScroll = cs;
		[cs release];
		
		[self addSubview:self.containerScroll];
		[self.containerScroll release];
		
		[self.containerScroll setContentSize:CGSizeMake(290.0, 580.0)];*/
		
		
		CGRect cvFrame = CGRectMake(15.0, -290.0, 290.0, 580.0);
		UIView *cv = [[UIView alloc] initWithFrame:cvFrame];
		[cv setBackgroundColor:[UIColor magentaColor]];
		self.containerView = cv;
		[cv release];
		
		[self addSubview:self.containerView];
		[self.containerView release];
		
		CGRect cFrame = CGRectMake(0.0, 0.0, 290.0, 580.0);
		UIView *c = [[UIView alloc] initWithFrame:cFrame];
		[c setBackgroundColor:[UIColor magentaColor]];
		self.container = c;
		[c release];
		
		[self.containerView addSubview:self.container];
		[self.container release];
		
		
		// SCROLL VIEW
		CGRect svFrame = CGRectMake(0.0, 0.0, 290.0, 290.0);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor yellowColor]];
		self.actionsScrollView = sv;
		[sv release];
		
		[self.container addSubview:self.actionsScrollView];
		[self.actionsScrollView release];
		

		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(5.0, 5.0, 280.0, 280.0);
		UIScrollView *av = [[UIScrollView alloc] initWithFrame:avFrame];
		[av setBackgroundColor:[UIColor blueColor]];
		self.actionsView = av;
		[av release];
		
		[self.actionsScrollView addSubview:self.actionsView];
		[self.actionsView release];
		
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(5.0, 290.0, 280.0, 280.0);
		TAPhotoView *iView = [[TAPhotoView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		[iView release];
		
		[self.container addSubview:self.imageView];
		[self.imageView release];
		
		// PROGRESS INDICATOR
		CGRect mainViewFrame = self.imageView.frame;
		CGFloat progressXPos = (mainViewFrame.size.width/2.0) - 75.0;
		CGFloat progressYPos = mainViewFrame.origin.y + ((mainViewFrame.size.height/2.0) - 4.0);
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self.container addSubview:self.progressView];
		[self.progressView release];
		
		// PULL BUTTON
		CGRect btnFrame = CGRectMake(120.0, 290.0, 80.0, 40.0);
		TAPullButton *pullBtn = [[TAPullButton alloc] initWithFrame:btnFrame];
		[pullBtn setFrame:btnFrame];
		[pullBtn setBackgroundColor:[UIColor cyanColor]];
		[pullBtn setDelegate:self];
		//[pullBtn addTarget:self action:@selector(pullButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.container addSubview:pullBtn];
		[pullBtn release];
		
		
		// IMAGE URL
		self.urlString = imageURLString;
		
		
		
		
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
	newFrame.origin.y +=  (-290.0 + yPos);
	
	[self.containerView setFrame:newFrame];
}


- (void)pullDownEnded:(CGFloat)lastYPos pullingUpward:(BOOL)pullingUpward {
	
	CGFloat yPos = (-290.0 + lastYPos);
	
	NSLog(@"%@", ((pullingUpward) ? @"PULLING UP" : @"PULLING DOWN"));
	NSLog(@"LAST Y POS:%.2f", lastYPos);
	
	if (pullingUpward) { 
	
		if (yPos >= -5.0) {
			
			CGRect newFrame = self.containerView.frame;
			newFrame.origin.y = -290.0;
			
			[UIView animateWithDuration:0.25 animations:^{
				
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


- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatarView.image) {
		
		NSLog(@"LOADING AVATAR IMAGE:%@", avatarURLString);
		
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


- (void)usernameClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate usernameButtonClicked];
}


- (void)pullButtonTapped:(id)sender { 

	NSLog(@"BUTTON TAPPED");
	
	//[self.delegate disableScroll];
	
	[self.containerScroll setScrollEnabled:YES];
	
	pullEnabled = YES;
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

@end
