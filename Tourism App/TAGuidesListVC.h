//
//  TAGuidesListVC.h
//  Tourism App
//
//  Created by Richard Lee on 22/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

typedef enum  {
	GuidesModeMyGuides = 0,
	GuidesModeFollowing = 1,
	GuidesModeAddTo = 2
} GuidesMode;

@interface TAGuidesListVC : UIViewController {
	
	GuidesMode guidesMode;
	
	BOOL loading;
	BOOL guidesLoaded;

	JSONFetcher *guidesFetcher;
	
	NSString *selectedCity;
	NSString *selectedTag;
	
	NSString *username;
	NSMutableArray *guides;
	
	IBOutlet UITableView *guidesTable;
}

@property GuidesMode guidesMode;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSMutableArray *guides;

@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) NSString *selectedTag;

@property (nonatomic, retain) IBOutlet UITableView *guidesTable;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
