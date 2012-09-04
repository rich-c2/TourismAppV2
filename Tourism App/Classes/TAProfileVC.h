//
//  TAProfileVC.h
//  Tourism App
//
//  Created by Richard Lee on 20/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TAProfileVC : UIViewController {

	// Data
	JSONFetcher *profileFetcher;
	JSONFetcher *isFollowingFetcher;
	JSONFetcher *unfollowFetcher;
	JSONFetcher *followFetcher;
	
	NSString *username;
	NSString *avatarURL;
	
	BOOL loading;
	BOOL profileLoaded;
	BOOL loadingIsFollowing;
	BOOL isFollowingLoaded;
	BOOL viewingCurrentUser;

	IBOutlet UIImageView *avatarView;
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *nameLabel;
	IBOutlet UIButton *photosBtn;
	
	IBOutlet UIButton *followUserBtn;
	IBOutlet UIButton *followingUserBtn;
	
	IBOutlet UIButton *followingBtn;
	IBOutlet UIButton *followersBtn;
	
	// MY CONTENT
	IBOutlet UIButton *myContentBtn;
	IBOutlet UIButton *findFriendsBtn;
	IBOutlet UIScrollView *contentScrollView;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;

@property (nonatomic, retain) IBOutlet UIImageView *avatarView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIButton *photosBtn;

@property (nonatomic, retain) IBOutlet UIButton *followUserBtn;
@property (nonatomic, retain) IBOutlet UIButton *followingUserBtn;

@property (nonatomic, retain) IBOutlet UIButton *followingBtn;
@property (nonatomic, retain) IBOutlet UIButton *followersBtn;

@property (nonatomic, retain) IBOutlet UIButton *myContentBtn;
@property (nonatomic, retain) IBOutlet UIButton *findFriendsBtn;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;


- (void)showLoading;
- (void)hideLoading;

- (void)loadUserDetails;
- (IBAction)followingButtonTapped:(id)sender;
- (IBAction)followersButtonTapped:(id)sender;

- (IBAction)followUserButtonTapped:(id)sender;
- (IBAction)followingUserButtonTapped:(id)sender;

- (IBAction)photosButtonTapped:(id)sender;

- (IBAction)myContentButtonTapped:(id)sender;
- (IBAction)findFriendsButtonTapped:(id)sender;

@end
