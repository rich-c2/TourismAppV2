//
//  TANotificationsVC.h
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TANotificationsVC : UIViewController {

	JSONFetcher *recommendationsFetcher;
	
	BOOL loading;
	BOOL recommendationsLoaded;
	
	NSMutableArray *reccomendations;
	IBOutlet UITableView *recommendationsTable;
}

@property (nonatomic, retain) NSMutableArray *reccomendations;
@property (nonatomic, retain) IBOutlet UITableView *recommendationsTable;

@end
