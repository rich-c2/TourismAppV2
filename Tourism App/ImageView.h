//
//  AlbumView.h
//  Fresh Tunes
//
//  Created by Richard Lee on 22/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@protocol ImageViewDelegate

- (void)usernameButtonClicked:(NSString *)selectedUser;
- (void)loveCountButtonClicked:(NSString *)imageID;
- (void)loveButtonClicked:(NSString *)imageID isLoved:(BOOL)loved;
- (void)commentButtonClicked:(NSString *)imageID;
- (void)cityTagButtonClicked:(NSString *)imageID;
- (void)optionsButtonClicked:(NSString *)imageID;
- (void)recommendButtonClicked;
- (void)flagButtonClicked:(NSString *)imageID;

@optional
- (void)mapButtonClicked:(NSString *)imageID;

@end

@interface ImageView : UIView {
	
	id <ImageViewDelegate> delegate;
	
	NSString *imageID;
	NSString *username;
	
	BOOL loved;
	NSInteger lovesCount;
	
	UIProgressView *progressView;

	UIImageView *avatarView;
	UIImageView *imageView;
	UIActivityIndicatorView *loadingSpinner;
	NSString *urlString;
	UIButton *loveButton;
	UIButton *lovesCountBtn;
	
	NSDictionary *locationData;
}

@property (nonatomic, retain) id <ImageViewDelegate> delegate;

@property (nonatomic, retain) UIProgressView *progressView;

@property (nonatomic, retain) NSString *imageID;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIActivityIndicatorView *loadingSpinner;
@property (nonatomic, retain) NSString *urlString;
@property (nonatomic, retain) UIButton *loveButton;
@property (nonatomic, retain) UIButton *lovesCountBtn;

@property (nonatomic, retain) NSDictionary *locationData;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString 
		   username:(NSString *)_username avatarURL:(NSString *)avatarURL
		 loves:(NSInteger)loves dateText:(NSString *)dateText cityText:(NSString *)cityText tagText:(NSString *)tagText verified:(BOOL)verified;
- (void)initAvatarImage:(NSString *)avatarURLString;
- (void)initImage;
- (void)isLoved:(BOOL)loveStatus;
- (void)updateLovesCount:(BOOL)addLove;

@end
