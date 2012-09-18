//
//  TAScrollVC.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUsersVC.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@class JSONFetcher;

@interface TAScrollVC : UIViewController <RecommendsDelegate> {
	
	// Toolbar buttons
	UIBarButtonItem *loveBtn;
	
	JSONFetcher *loveFetcher;
	JSONFetcher *recommendFetcher;
	JSONFetcher *feedFetcher;
	JSONFetcher *vouchFetcher;
	JSONFetcher *flagFetcher;
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;
	
	NSInteger scrollIndex;
	
	IBOutlet UIScrollView *photosScrollView;
	
	NSMutableArray *photos;
	NSMutableArray *loveIDs;
	NSMutableArray *vouchedIDs;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *loveBtn;

@property (nonatomic, retain) IBOutlet UIScrollView *photosScrollView;

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSMutableArray *loveIDs;
@property (nonatomic, retain) NSMutableArray *vouchedIDs;

- (IBAction)loveButtonTapped:(id)sender;
- (IBAction)commentButtonTapped:(id)sender;
- (IBAction)mapButtonTapped:(id)sender;
- (IBAction)recommendButtonTapped:(id)sender;
- (IBAction)moreButtonTapped:(id)sender;

@end
