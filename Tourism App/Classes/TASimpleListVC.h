//
//  TASimpleListVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tag.h"

typedef enum  {
	ListModeLovedBy = 0,
	ListModeTags = 1
} ListMode;

@class JSONFetcher;

@protocol TagsDelegate

@optional
- (void)tagSelected:(Tag *)tag;

@end

@interface TASimpleListVC : UIViewController {
	
	id <TagsDelegate> delegate;
	
	NSManagedObjectContext *managedObjectContext;

	ListMode listMode;
	NSString *imageCode;
	
	JSONFetcher *fetcher;
	NSArray *listItems;
	
	IBOutlet UITableView *listTable;
	
	BOOL usersLoaded;
	BOOL loading;
}

@property (nonatomic, retain) id <TagsDelegate> delegate;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property ListMode listMode;
@property (nonatomic, retain) NSString *imageCode;

@property (nonatomic, retain) NSArray *listItems;

@property (nonatomic, retain) IBOutlet UITableView *listTable;


@end
