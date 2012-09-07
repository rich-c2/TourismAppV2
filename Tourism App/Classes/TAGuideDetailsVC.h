//
//  TAGuideDetailsVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"
#import "TAUsersVC.h"

@class JSONFetcher;

typedef enum  {
	GuideModeCreated = 0,
	GuideModeViewing = 1
} GuideMode;

@interface TAGuideDetailsVC : UIViewController <GridImageDelegate, UIActionSheetDelegate, RecommendsDelegate> {

	GuideMode guideMode;
	
	JSONFetcher *guideFetcher;
	JSONFetcher *isLovedFetcher;
	JSONFetcher *loveFetcher;
	JSONFetcher *recommendFetcher;
	
	NSDictionary *guideData;
	NSMutableArray *images;
	NSString *guideID;
	
	BOOL isLoved;
	BOOL loading;
	BOOL guideLoaded;
	
	IBOutlet UIButton *authorBtn;
	IBOutlet UIScrollView *gridScrollView;
	IBOutlet UIImageView *guideThumb;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIView *imagesView;
}

@property GuideMode guideMode;

@property (nonatomic, retain) NSDictionary *guideData;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSString *guideID;

@property (nonatomic, retain) IBOutlet UIButton *authorBtn;
@property (nonatomic, retain) IBOutlet UIScrollView *gridScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *guideThumb;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIView *imagesView;

- (IBAction)authorButtonTapped:(id)sender;
- (IBAction)optionsButtonTapped:(id)sender;
- (IBAction)initFollowersList:(id)sender;

@end
