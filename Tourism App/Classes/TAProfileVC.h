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

	IBOutlet UILabel *nameLabel;
	IBOutlet UIButton *photosBtn;
	
	IBOutlet UIButton *followUserBtn;
	IBOutlet UIButton *followingUserBtn;
	
	IBOutlet UIButton *followingBtn;
	IBOutlet UIButton *followersBtn;
}

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIButton *photosBtn;

@property (nonatomic, retain) IBOutlet UIButton *followUserBtn;
@property (nonatomic, retain) IBOutlet UIButton *followingUserBtn;

@property (nonatomic, retain) IBOutlet UIButton *followingBtn;
@property (nonatomic, retain) IBOutlet UIButton *followersBtn;

- (void)showLoading;
- (void)hideLoading;

- (void)loadUserDetails;
- (IBAction)followingButtonTapped:(id)sender;
- (IBAction)followersButtonTapped:(id)sender;

- (IBAction)followUserButtonTapped:(id)sender;
- (IBAction)followingUserButtonTapped:(id)sender;

@end
