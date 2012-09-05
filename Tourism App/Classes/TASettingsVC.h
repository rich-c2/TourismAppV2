//
//  TASettingsVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "TACitiesListVC.h"

@class JSONFetcher;

@interface TASettingsVC : UIViewController <CitiesDelegate, MFMailComposeViewControllerDelegate> {

	NSMutableDictionary *menuDictionary;
	NSArray *keys;
	
	IBOutlet UITableView *settingsTable;
	
	JSONFetcher *profileFetcher;
}

@property (nonatomic, retain) NSMutableDictionary *menuDictionary;
@property (nonatomic, retain) NSArray *keys;

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;

@end
