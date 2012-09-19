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

@synthesize imageView, progressView, urlString, delegate, avatarView;


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

@end
