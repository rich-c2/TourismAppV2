//
//  TAPhotoFrame.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PhotoFrameDelegate

- (void)usernameButtonClicked;
/*- (void)loveCountButtonClicked:(NSString *)imageID;
- (void)loveButtonClicked:(NSString *)imageID isLoved:(BOOL)loved;
- (void)commentButtonClicked:(NSString *)imageID;
- (void)cityTagButtonClicked:(NSString *)imageID;
- (void)optionsButtonClicked:(NSString *)imageID;
- (void)recommendButtonClicked;
- (void)flagButtonClicked:(NSString *)imageID;

@optional
- (void)mapButtonClicked:(NSString *)imageID;*/

@end

@interface TAPhotoFrame : UIView {
	
	id <PhotoFrameDelegate> delegate;
	
	UIImageView *avatarView;
	UIImageView *imageView;
	UIProgressView *progressView;
	NSString *urlString;
}

@property (nonatomic, retain) id <PhotoFrameDelegate> delegate;

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *urlString;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString 
			caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL;
- (void)initImage;
- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url;


@end
