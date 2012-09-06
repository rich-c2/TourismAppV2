//
//  AlbumView.m
//  Fresh Tunes
//
//  Created by Richard Lee on 22/11/11.
//  Copyright (c) 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "ImageView.h"
#import "UIImageView+AFNetworking.h"
#import "ImageManager.h"

@implementation ImageView

@synthesize delegate, imageID, username, loveButton, lovesCountBtn, locationData;
@synthesize avatarView, imageView, urlString, loadingSpinner, progressView;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString 
		   username:(NSString *)_username avatarURL:(NSString *)avatarURL
			  loves:(NSInteger)loves dateText:(NSString *)dateText cityText:(NSString *)cityText tagText:(NSString *)tagText verified:(BOOL)verified {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		lovesCount = loves;
		
		// Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 45.0, 45.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self addSubview:self.avatarView];
		[self.avatarView release];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
		
		// Username button
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(55.0, 0.0, 195.0, 25.0)];
		[btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitle:_username forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
		[self addSubview:btn];
		
		
		// City/Tag label
		NSString *btnTitle = [NSString stringWithFormat:@"%@/%@", cityText, tagText];
		UIButton *cityTagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[cityTagBtn setFrame:CGRectMake(55.0, 20.0, 130.0, 25.0)];
		[cityTagBtn setBackgroundColor:[UIColor clearColor]];
		[cityTagBtn setTitle:btnTitle forState:UIControlStateNormal];
		[cityTagBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[cityTagBtn addTarget:self action:@selector(cityTagClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[cityTagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
		[cityTagBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[self addSubview:cityTagBtn];
		
		
		// Verified
		UIView *verifiedView = [[UIView alloc] initWithFrame:CGRectMake(213.0, 0.0, 25.0, 25.0)];
		
		UIColor *bgColor;
		bgColor = ((verified) ? [UIColor greenColor] : [UIColor redColor]);		
		
		[verifiedView setBackgroundColor:bgColor];
		[self addSubview:verifiedView];
		[verifiedView release];
		
		
		// Date label
		UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(250.0, 0.0, 50.0, 25.0)];
		[dateLabel setBackgroundColor:[UIColor clearColor]];
		[dateLabel setText:dateText];
		[dateLabel setFont:[UIFont boldSystemFontOfSize:13.0]];
		[dateLabel setTextAlignment:UITextAlignmentRight];		
		[self addSubview:dateLabel];
		[dateLabel release];
		

		// Main image view
		CGRect iViewFrame = CGRectMake(0.0, 50.0, 300.0, 300.0);
		UIImageView *iView = [[UIImageView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		[iView release];
		
		[self addSubview:self.imageView];
		[self.imageView release];
		
		// Love count button
		self.lovesCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.lovesCountBtn setFrame:CGRectMake(0.0, 360.0, 75.0, 25.0)];
		[self.lovesCountBtn setBackgroundColor:[UIColor clearColor]];
		[self.lovesCountBtn setTitle:[NSString stringWithFormat:@"%i loves", lovesCount] forState:UIControlStateNormal];
		[self.lovesCountBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
		[self.lovesCountBtn addTarget:self action:@selector(loveCountButtonClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[self.lovesCountBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[self.lovesCountBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
		[self addSubview:self.lovesCountBtn];
		
		// Love button
		self.loveButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.loveButton setFrame:CGRectMake(0.0, 390.0, 75.0, 25.0)];
		[self.loveButton setBackgroundColor:[UIColor grayColor]];
		[self.loveButton setTitle:@"love" forState:UIControlStateNormal];
		[self.loveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.loveButton addTarget:self action:@selector(loveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[self.loveButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
		[self addSubview:self.loveButton];
		
		// Comment button
		UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[commentBtn setFrame:CGRectMake(85.0, 390.0, 75.0, 25.0)];
		[commentBtn setBackgroundColor:[UIColor grayColor]];
		[commentBtn setTitle:@"comment" forState:UIControlStateNormal];
		[commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[commentBtn addTarget:self action:@selector(commentButtonClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[commentBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];	
		[self addSubview:commentBtn];
		
		// Map button
		UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[mapBtn setFrame:CGRectMake(170.0, 390.0, 75.0, 25.0)];
		[mapBtn setBackgroundColor:[UIColor grayColor]];
		[mapBtn setTitle:@"map" forState:UIControlStateNormal];
		[mapBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[mapBtn addTarget:self action:@selector(mapButtonClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[mapBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];	
		[self addSubview:mapBtn];
		
		
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
		
		NSLog(@"LOADING IMAGE:%@", self.urlString);
		
		//[self.loadingSpinner startAnimating];
		
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
	[self.delegate usernameButtonClicked:self.username];
}


- (void)loveCountButtonClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveCountButtonClicked:self.imageID];
}


- (void)loveButtonClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveButtonClicked:self.imageID isLoved:loved];
}


- (void)commentButtonClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate commentButtonClicked:self.imageID];
}


- (void)mapButtonClicked:(id)sender {
		
	// pass info on to delegate
	[self.delegate mapButtonClicked:self.imageID location:self.locationData];
}


- (void)cityTagClicked:(id)sender {

	// pass info on to delegate
	[self.delegate cityTagButtonClicked:self.imageID];
}


- (void)isLoved:(BOOL)loveStatus {

	loved = loveStatus;
	
	NSString *status = [NSString stringWithFormat:@"%@", ((loved) ? @"Loved" : @"Love")];
	
	// Update love button title
	[self.loveButton setTitle:status forState:UIControlStateNormal];
	
	if (loved) [self.loveButton setBackgroundColor:[UIColor redColor]];
	else [self.loveButton setBackgroundColor:[UIColor grayColor]];
}


- (void)updateLovesCount:(BOOL)addLove {

	lovesCount = ((addLove) ? (lovesCount+1) : (lovesCount-1));
	[self.lovesCountBtn setTitle:[NSString stringWithFormat:@"%i loves", lovesCount] forState:UIControlStateNormal];
}


@end
