//
//  TAFriendsVC.h
//  Tourism App
//
//  Created by Richard Lee on 4/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAFriendsVC : UIViewController {

	
	IBOutlet UITableView *friendsTable;
	
	NSArray *tableContent;
}

@property (nonatomic, retain) IBOutlet UITableView *friendsTable;
@property (nonatomic, retain) NSArray *tableContent;

@end
