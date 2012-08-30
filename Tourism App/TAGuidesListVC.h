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
	GuidesModeViewing = 2,
	GuidesModeAddTo = 3,
	GuidesModeSearchResults = 4
} GuidesMode;

@interface TAGuidesListVC : UIViewController {
	
	GuidesMode guidesMode;
	
	BOOL loading;
	BOOL guidesLoaded;

	JSONFetcher *guidesFetcher;
	
	NSString *selectedPhotoID;
	NSString *selectedCity;
	NSString *selectedTag;
	NSNumber *selectedTagID;
	
	NSString *username;
	NSMutableArray *guides;
	
	IBOutlet UITableView *guidesTable;
}

@property GuidesMode guidesMode;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSMutableArray *guides;

@property (nonatomic, retain) NSString *selectedPhotoID;
@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) NSString *selectedTag;
@property (nonatomic, retain) NSNumber *selectedTagID;

@property (nonatomic, retain) IBOutlet UITableView *guidesTable;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
