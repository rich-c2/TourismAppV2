//
//  GridImage.m
//  GiftHype
//
//  Created by Richard Lee on 24/11/11.
//  Copyright (c) 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "GridImage.h"
#import "ImageManager.h"
#import "DictionaryHelper.h"
#import "StringHelper.h"
#import "UIImageView+AFNetworking.h"

#define TICK_MARK_VIEW_TAG 9000
#define CLOSE_VIEW_TAG 8000
#define IMAGE_WIDTH 83.0
#define IMAGE_HEIGHT 83.0

@implementation GridImage

@synthesize imageView, imageURL, delegate;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		// Close view and tick mark view were added to this class
		// for the purpose of enabling a GridImage to be selected/deselected
		// FOR NOW - remove this.
		
		// CLOSE view
		/*
		UIImage *closeImage = [UIImage imageNamed:@"red-close-button-small.png"];
		CGFloat xPos = frame.size.width - (closeImage.size.width + 6);
		CGFloat yPos = frame.size.height - (closeImage.size.height + 6);
		UIImageView *closeView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, closeImage.size.width, closeImage.size.height)];
		[closeView setTag:CLOSE_VIEW_TAG];
		[closeView setImage:closeImage];
		[self addSubview:closeView];
		[closeView release];
		
		
		// Tick mark view
		UIImageView *tickMarkView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[tickMarkView setTag:TICK_MARK_VIEW_TAG];
		[tickMarkView setBackgroundColor:[UIColor blackColor]];
		[tickMarkView setAlpha:.75];
		[self addSubview:tickMarkView];
		[tickMarkView release];
		*/
		
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[polaroidBG setImage:[UIImage imageNamed:@"thumb-polaroid-bg.png"]];
		[self addSubview:polaroidBG];
		[polaroidBG release];
		
        
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(10.0, 10.0, IMAGE_WIDTH, IMAGE_HEIGHT)];
		[btn setBackgroundColor:[UIColor magentaColor]];
		[btn addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn setContentMode:UIViewContentModeScaleAspectFill];
		
		self.imageView = btn;
		
		[self addSubview:self.imageView];
		[self.imageView release];
		
		// Start downloading image
		[self initImage:imageURLString];
    }
	
    return self;
}


- (void)dealloc {
	
	/*[imageView release]; 
	[imageURL release]; 
	
	self.delegate = nil;*/
	
	[super dealloc];
}


- (void) drawContentView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	[[UIColor whiteColor] set];
	CGContextFillRect(context, rect);
	
	if (self.imageURL) {
		
		UIImage* img = [ImageManager loadImage:imageURL progressIndicator:nil];
		
		if (img) {
			
			CGRect r = CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height);
			[img drawInRect:r];
		}
	}
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {
		
		self.imageURL = [urlString convertToURL];
		
		UIImage* img = [ImageManager loadImage:imageURL progressIndicator:nil];
		if (img) {
			
			[self.imageView setImage:img forState:UIControlStateNormal];
		}
    }
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([imageURL isEqual:url]) {
		
		NSLog(@"IMAGE LOADED:%@", [url description]);
		
		[self.imageView setImage:image forState:UIControlStateNormal];
	}
}


- (void)imageButtonClicked:(id)sender {
	
	NSLog(@"CLICK!");

	[self.delegate gridImageButtonClicked:self.tag];
}


- (void)editing {

	editMode = !editMode;
	NSLog(@"editMode:%@", (editMode ? @"NO" : @"YES"));
	
	UIView *closeView = [self viewWithTag:CLOSE_VIEW_TAG];
	if (editMode) [self bringSubviewToFront:closeView];
	else [self sendSubviewToBack:closeView];
}


- (void)select {
	
	// Hide the black transparent view
	UIView *tickMarkView = [self viewWithTag:TICK_MARK_VIEW_TAG];
	[self sendSubviewToBack:tickMarkView];
	
	// Show the close view
	UIView *closeView = [self viewWithTag:CLOSE_VIEW_TAG];
	[self bringSubviewToFront:closeView];
}


- (void)deselect {

	// Show the black transparent view
	UIView *tickMarkView = [self viewWithTag:TICK_MARK_VIEW_TAG];
	[self bringSubviewToFront:tickMarkView];
	
	// Hide the close view
	UIView *closeView = [self viewWithTag:CLOSE_VIEW_TAG];
	[self sendSubviewToBack:closeView];
}


@end
