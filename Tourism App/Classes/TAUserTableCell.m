//
//  TAUserTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUserTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation TAUserTableCell

@synthesize nameLabel, usernameLabel, thumbView, cellSpinner, imageURL;
@synthesize followBtn, followingBtn;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)USER_CELL_IDENTIFIER;
}


- (NSString *)reuseIdentifier {
	
    return [[self class] reuseIdentifier];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initImage:(NSString *)urlString {
	
	// TEST CODE
	if (urlString) {
		
		self.imageURL = [urlString convertToURL];
		
		NSLog(@"LOADING GRID IMAGE:%@", urlString);
		
		UIImage* img = [ImageManager loadImage:imageURL];
		if (img) {
			
			[self.thumbView setImage:img];
			[self.cellSpinner stopAnimating];
		}
    }
	
	else {
		
		[self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
		[self.cellSpinner stopAnimating];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.imageURL isEqual:url]) {
		
		if (image != nil) {
			
			NSLog(@"IMAGE LOADED:%@", [url description]);
			[self.thumbView setImage:image];
			[self.cellSpinner stopAnimating];
		}
		
		else [self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
	}
}


- (void)setFollowingUser:(BOOL)following {

	if (following) self.followingBtn.hidden = NO;
	else self.followBtn.hidden = NO;
}


- (void)dealloc {
	
	[followBtn release]; 
	[followingBtn release];
	
	[imageURL release];
	[cellSpinner release];
	[usernameLabel release];
	[thumbView release];
	[nameLabel release];
	
    [super dealloc];
}

@end
