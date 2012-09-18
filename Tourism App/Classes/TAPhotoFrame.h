//
//  TAPhotoFrame.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAPhotoFrame : UIView {
	
	UIImageView *imageView;
	UIProgressView *progressView;
	NSString *urlString;
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *urlString;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString;
- (void)initImage;
- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url;


@end
