//
//  TAPhotoFrame.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPullButton.h"
#import "TAPhotoView.h"


@protocol PhotoFrameDelegate

- (void)disableScroll;
- (void)enableScroll;
- (void)usernameButtonClicked;
- (void)loveButtonTapped:(NSString *)imageID;
- (void)vouchButtonTapped:(NSString *)imageID;
//- (void)loveCountButtonClicked:(NSString *)imageID;
/*- (void)commentButtonClicked:(NSString *)imageID;
- (void)cityTagButtonClicked:(NSString *)imageID;
- (void)optionsButtonClicked:(NSString *)imageID;
- (void)recommendButtonClicked;
- (void)flagButtonClicked:(NSString *)imageID;

@optional
- (void)mapButtonClicked:(NSString *)imageID;*/

@end

@interface TAPhotoFrame : UIView <UIScrollViewDelegate, PullButtonDelegate> {
	
	// TEST
	UIView *containerView;
	UIView *container;
	UIScrollView *containerScroll;
	UIScrollView *actionsScrollView;
	UIView *actionsView;
	BOOL pullEnabled;
	
	NSString *imageID;
	
	id <PhotoFrameDelegate> delegate;
	
	UIImageView *avatarView;
	TAPhotoView *imageView;
	UIProgressView *progressView;
	NSString *urlString;
}

@property (nonatomic, retain) id <PhotoFrameDelegate> delegate;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *container;
@property (nonatomic, retain) UIScrollView *containerScroll;
@property (nonatomic, retain) UIScrollView *actionsScrollView;
@property (nonatomic, retain) UIView *actionsView;

@property (nonatomic, retain) NSString *imageID;

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) TAPhotoView *imageView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *urlString;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)_imageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL;

- (void)initImage;
- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url;


@end
