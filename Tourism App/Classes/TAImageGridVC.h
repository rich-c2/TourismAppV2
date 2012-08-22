//
//  TAImageGridVC.h
//  Tourism App
//
//  Created by Richard Lee on 21/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"

@class JSONFetcher;

@interface TAImageGridVC : UIViewController <GridImageDelegate> {
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;

	IBOutlet UIButton *loadMoreButton;
	IBOutlet UIView *imagesView;
	IBOutlet UIScrollView *gridScrollView;
	
	JSONFetcher *imagesFetcher;
	
	BOOL loading;
	BOOL imagesLoaded;
	
	NSString *username;
	NSMutableArray *images;
}

@property (nonatomic, retain) IBOutlet UIButton *loadMoreButton;
@property (nonatomic, retain) IBOutlet UIView *imagesView;
@property (nonatomic, retain) IBOutlet UIScrollView *gridScrollView;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) IBOutlet NSMutableArray *images;

- (IBAction)loadMoreButtonClicked:(id)sender;

@end
