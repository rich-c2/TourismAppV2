
//
//  TACommentsVC.h
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TACommentsVC : UIViewController {

	JSONFetcher *commentsFetcher;
	
	BOOL loading;
	BOOL commentsLoaded;
	
	NSString *imageCode;
	NSMutableArray *comments;
	
	IBOutlet UITableView *commentsTable;
}

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSMutableArray *comments;

@property (nonatomic, retain) IBOutlet UITableView *commentsTable;

@end
