//
//  TAPhotoFrame.m
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPhotoFrame.h"
#import "UIImageView+AFNetworking.h"
#import "ImageManager.h"

#define MAIN_IMAGE_WIDTH 280
#define MAIN_IMAGE_HEIGHT 280

@implementation TAPhotoFrame

@synthesize imageView, progressView, urlString;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		// Main image view
		CGRect iViewFrame = CGRectMake(20.0, 20.0, MAIN_IMAGE_WIDTH, MAIN_IMAGE_HEIGHT);
		UIImageView *iView = [[UIImageView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		[iView release];
		
		[self addSubview:self.imageView];
		[self.imageView release];
		
		// PROGRESS INDICATOR
		CGRect mainViewFrame = self.frame;
		CGFloat progressXPos = (mainViewFrame.size.width/2.0) - 75.0;
		CGFloat progressYPos = (mainViewFrame.size.height/2.0) - 4.0;
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self addSubview:self.progressView];
		[self.progressView release];
		
		self.urlString = imageURLString;
    }
    return self;
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


@end
