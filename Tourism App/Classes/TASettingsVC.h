//
//  TASettingsVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TASettingsVC : UIViewController {

	NSArray *listItems;
	
	IBOutlet UITableView *settingsTable;
}

@property (nonatomic, retain) NSArray *listItems;

@property (nonatomic, retain) IBOutlet UITableView *settingsTable;

@end
