//
//  TASimpleListVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
	ListModeLovedBy = 0
} ListMode;

@class JSONFetcher;

@interface TASimpleListVC : UIViewController {

	ListMode listMode;
	NSString *imageCode;
	
	JSONFetcher *fetcher;
	NSMutableArray *listItems;
	
	IBOutlet UITableView *listTable;
	
	BOOL usersLoaded;
	BOOL loading;
}

@property ListMode listMode;
@property (nonatomic, retain) NSString *imageCode;

@property (nonatomic, retain) NSMutableArray *listItems;

@property (nonatomic, retain) IBOutlet UITableView *listTable;


@end
