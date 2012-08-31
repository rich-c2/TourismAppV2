//
//  TAMediaResultsVC.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TAMediaResultsVC : UIViewController {

	IBOutlet UIButton *photosBtn;
	IBOutlet UIButton *guidesBtn;
	
	JSONFetcher *mediaFetcher;
	JSONFetcher *guidesFetcher;
	
	IBOutlet UILabel *cityLabel;
	IBOutlet UILabel *tagLabel;
	NSNumber *tagID;
	NSString *tag;
	NSString *city;
	
	NSMutableArray *guides;
	NSMutableArray *images;
}

@property (nonatomic, retain) IBOutlet UIButton *photosBtn;
@property (nonatomic, retain) IBOutlet UIButton *guidesBtn;

@property (nonatomic, retain) NSNumber *tagID;
@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSString *city;

@property (nonatomic, retain) NSMutableArray *guides;
@property (nonatomic, retain) NSMutableArray *images;

@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet UILabel *tagLabel;

@end
