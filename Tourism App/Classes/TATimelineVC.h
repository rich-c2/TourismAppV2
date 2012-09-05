//
//  TATimelineVC.h
//  Tourism App
//
//  Created by Richard Lee on 5/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageView.h"

@class JSONFetcher;

@interface TATimelineVC : UIViewController <ImageViewDelegate> {

	// love fetcher
	JSONFetcher *loveFetcher;
	
	IBOutlet UIScrollView *timelineScrollView;
	NSInteger scrollIndex;
	
	NSString *selectedImageID;
	
	NSArray *images;
	
	BOOL imageViewsReady;
	BOOL loading;
	BOOL loaded;
	
	NSTimer *loadedTimer;
}

@property (nonatomic, retain) IBOutlet UIScrollView *timelineScrollView;
@property (nonatomic, retain) NSString *selectedImageID;

@property (nonatomic, retain) NSArray *images;

@end
