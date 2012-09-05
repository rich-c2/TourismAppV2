//
//  TAFeedVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"

@class JSONFetcher;

typedef enum {
    FeedModeFeed = 0,
	FeedModeLatest = 1, 
    FeedModePopular = 2, 
	FeedModeCity = 3 
} FeedMode;

@interface TAFeedVC : UIViewController <GridImageDelegate, UIActionSheetDelegate> {
	
	FeedMode feedMode;
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;
	
	IBOutlet UIView *imagesView;
	IBOutlet UIScrollView *gridScrollView;
	
	JSONFetcher *imagesFetcher;
	
	BOOL loading;
	BOOL imagesLoaded;
	BOOL refresh;
	
	NSMutableArray *images;
}

@property FeedMode feedMode;

@property (nonatomic, retain) IBOutlet UIView *imagesView;
@property (nonatomic, retain) IBOutlet UIScrollView *gridScrollView;

@property (nonatomic, retain) IBOutlet NSMutableArray *images;

- (void)willLogout;


@end
