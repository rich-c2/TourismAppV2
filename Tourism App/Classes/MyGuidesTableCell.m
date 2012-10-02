//
//  MyGuidesTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 1/10/12.
//
//

#import "MyGuidesTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation MyGuidesTableCell

@synthesize titleLabel, authorLabel, thumbView, cellSpinner, imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)GUIDE_CELL_IDENTIFIER;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initImage:(NSString *)urlString {
	
	// TEST CODE
	if (urlString) {
		
		self.imageURL = [urlString convertToURL];
		
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
			
			[self.thumbView setImage:image];
			[self.cellSpinner stopAnimating];
		}
		
		else [self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
	}
}


- (void)dealloc {
	
	[imageURL release];
	[cellSpinner release];
	[titleLabel release];
	[thumbView release];
	[authorLabel release];
	
    [super dealloc];
}

@end
