//
//  TACitiesListVC.h
//  Tourism App
//
//  Created by Richard Lee on 30/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"

@class JSONFetcher;
@class MyCoreLocation;
@class XMLFetcher;
@class DefaultCityCell;

@protocol CitiesDelegate

- (void)locationSelected:(NSDictionary *)city;

@end

@interface TACitiesListVC : UIViewController {
	
	IBOutlet DefaultCityCell *loadCell;
	
	IBOutlet UIButton *setBtn;
	
	IBOutlet UIButton *locateBtn;

	id <CitiesDelegate> delegate;
		
	JSONFetcher *citiesFetcher;
	
	BOOL loading;
	BOOL citiesLoaded;
		
	IBOutlet UITextField *searchField;
	IBOutlet UITableView *citiesTable;
	NSArray *cities;
	NSDictionary *selectedCity;
	
	XMLFetcher *cityFetcher;
	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) IBOutlet DefaultCityCell *loadCell;

@property (nonatomic, retain) IBOutlet UIButton *setBtn;

@property (nonatomic, retain) IBOutlet UIButton *locateBtn;

@property (nonatomic, retain) id <CitiesDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField *searchField;
@property (nonatomic, retain) IBOutlet UITableView *citiesTable;
@property (nonatomic, retain) NSArray *cities;
@property (nonatomic, retain) NSDictionary *selectedCity;

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (IBAction)goBack:(id)sender;
- (IBAction)setButtonTapped:(id)sender;

@end
