//
//  TAImageDetailsVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TAImageDetailsVC : UIViewController {
	
	// Data
	NSString *imageCode;
	JSONFetcher *mediaFetcher;
	NSDictionary *imageData;
	NSURL *avatarURL;
	NSURL *selectedURL;
	
	BOOL imageLoaded;
	BOOL loading;

	IBOutlet UIScrollView *scrollView;
	
	IBOutlet UIProgressView *progressIndicator;

	IBOutlet UIImageView *avatar;
	IBOutlet UIButton *usernameBtn;
	IBOutlet UIButton *subtitle;
	
	IBOutlet UIImageView *mainPhoto;
	IBOutlet UILabel *captionLabel;
	
	IBOutlet UIButton *loveBtn;
	IBOutlet UIButton *mapBtn;
	IBOutlet UIButton *commentBtn;
	IBOutlet UIButton *lovesCountBtn;
	
}

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSDictionary *imageData;
@property (nonatomic, retain) NSURL *avatarURL;
@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicator;

@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) IBOutlet UIButton *usernameBtn;
@property (nonatomic, retain) IBOutlet UIButton *subtitle;

@property (nonatomic, retain) IBOutlet UIImageView *mainPhoto;
@property (nonatomic, retain) IBOutlet UILabel *captionLabel;

@property (nonatomic, retain) IBOutlet UIButton *loveBtn;
@property (nonatomic, retain) IBOutlet UIButton *mapBtn;
@property (nonatomic, retain) IBOutlet UIButton *commentBtn;
@property (nonatomic, retain) IBOutlet UIButton *lovesCountBtn;

- (IBAction)lovesCountButtonTapped:(id)sender;

@end
