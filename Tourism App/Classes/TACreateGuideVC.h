//
//  TACreateGuideVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAUsersVC.h"

@class JSONFetcher;

@interface TACreateGuideVC : UIViewController <RecommendsDelegate> {

	JSONFetcher *fetcher;
	JSONFetcher *recommendFetcher;
	
	NSMutableArray *recommendToUsernames;
	
	NSString *imageCode;
	NSNumber *guideTagID;
	NSString *guideCity;
	
	IBOutlet UILabel *tagLabel;
	IBOutlet UILabel *cityLabel;
	IBOutlet UITextField *titleField;
}

@property (nonatomic, retain) NSMutableArray *recommendToUsernames;

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSNumber *guideTagID;
@property (nonatomic, retain) NSString *guideCity;

@property (nonatomic, retain) IBOutlet UILabel *tagLabel;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet UITextField *titleField;

- (IBAction)submitButtonTapped:(id)sender;
- (IBAction)recommendButtonTapped:(id)sender;

@end
