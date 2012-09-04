//
//  TACitiesListVC.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@protocol CitiesDelegate

- (void)locationSelected:(NSDictionary *)city;

@end

@interface TACitiesListVC : UIViewController {

	id <CitiesDelegate> delegate;
	
	JSONFetcher *citiesFetcher;
	
	BOOL loading;
	BOOL citiesLoaded;
		
	IBOutlet UISearchBar *searchField;
	IBOutlet UITableView *citiesTable;
	NSArray *cities;
}

@property (nonatomic, retain) id <CitiesDelegate> delegate;

@property (nonatomic, retain) IBOutlet UISearchBar *searchField;
@property (nonatomic, retain) IBOutlet UITableView *citiesTable;
@property (nonatomic, retain) NSArray *cities;

@end
