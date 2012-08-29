//
//  TACreateGuideVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TACreateGuideVC : UIViewController {

	JSONFetcher *fetcher;
	
	NSString *imageCode;
	NSNumber *guideTagID;
	NSString *guideCity;
	
	IBOutlet UITextField *titleField;
}

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSNumber *guideTagID;
@property (nonatomic, retain) NSString *guideCity;

@property (nonatomic, retain) IBOutlet UITextField *titleField;

- (IBAction)submitButtonTapped:(id)sender;

@end
