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

@interface TASettingsVC : UIViewController <CitiesDelegate, MFMailComposeViewControllerDelegate> {

	NSDictionary *menuDictionary;
	NSArray *keys;
	
	IBOutlet UITableView *settingsTable;
}

@property (nonatomic, retain) NSDictionary *menuDictionary;
@property (nonatomic, retain) NSArray *keys;

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;

@end
