//
//  TATimelineVC.h
//  Tourism App
//
//  Created by Richard Lee on 5/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TAUsersVC.h"

@class JSONFetcher;

@interface TATimelineVC : UIViewController <ImageViewDelegate, UIActionSheetDelegate, RecommendsDelegate> {

	NSManagedObjectContext *managedObjectContext;
	
	// love fetcher
	JSONFetcher *loveFetcher;
	JSONFetcher *vouchFetcher;
	JSONFetcher	*recommendFetcher;
	
	IBOutlet UIScrollView *timelineScrollView;
	NSInteger scrollIndex;
	
	NSString *selectedImageID;
	
	NSArray *images;
	NSMutableArray *photos;
	
	BOOL imageViewsReady;
	BOOL loading;
	BOOL loaded;
	
	NSTimer *loadedTimer;
	
	NSMutableDictionary *imagesDictionary;
	UIBarButtonItem *addToGuideBtn;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UIScrollView *timelineScrollView;
@property (nonatomic, retain) NSString *selectedImageID;

@property (nonatomic, retain) NSArray *images;
@property (nonatomic, retain) NSMutableArray *photos;

@property (nonatomic, retain) NSMutableDictionary *imagesDictionary;
@property (nonatomic, retain) UIBarButtonItem *addToGuideBtn;

@end
