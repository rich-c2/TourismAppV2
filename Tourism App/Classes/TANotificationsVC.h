//
//  TANotificationsVC.h
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

typedef enum  {
	NotificationsCategoryRecommendations = 0,
	NotificationsCategoryMe = 1, 
	NotificationsCategoryFollowing = 2
} NotificationsCategory;

@interface TANotificationsVC : UIViewController {

	JSONFetcher *recommendationsFetcher;
	JSONFetcher *followingFetcher;
	JSONFetcher *meFetcher;
	
	BOOL loading;
	BOOL recommendationsLoaded;
	
	NSMutableArray *notifications;
	NSMutableArray *reccomendations;
	NSMutableArray *meItems;
	NSMutableArray *following;
	
	IBOutlet UISegmentedControl *tabsControl;
	IBOutlet UITableView *recommendationsTable;
}

@property (nonatomic, retain) NSMutableArray *notifications;
@property (nonatomic, retain) NSMutableArray *reccomendations;
@property (nonatomic, retain) NSMutableArray *meItems;
@property (nonatomic, retain) NSMutableArray *following;

@property (nonatomic, retain) IBOutlet UISegmentedControl *tabsControl;
@property (nonatomic, retain) IBOutlet UITableView *recommendationsTable;

- (NSString *)getSelectedCategory;
- (void)willLogout;

@end
