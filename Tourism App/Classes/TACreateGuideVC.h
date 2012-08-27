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
}

- (IBAction)addToGuideButtonTapped:(id)sender;

@end
