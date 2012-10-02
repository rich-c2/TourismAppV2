//
//  TAExploreVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TASimpleListVC.h"
#import "TACitiesListVC.h"
#import "CoreLocation/CoreLocation.h"

@class Tag;
@class MyCoreLocation;
@class XMLFetcher;

typedef enum {
	ExploreModeRegular = 0,
	ExploreModeSubset = 1
} ExploreMode;


@protocol ExploreDelegate

- (void)finishedFilteringWithPhotos:(NSArray *)results;

@end


@interface TAExploreVC : UIViewController <TagsDelegate, CitiesDelegate> {
	
	id <ExploreDelegate> delegate;
	
	IBOutlet UIView *filterView;
	BOOL filtering;
	
	XMLFetcher *cityFetcher;
	
	ExploreMode exploreMode;
	NSMutableArray *images;
	NSMutableArray *photos;
	
	Tag *selectedTag;
	IBOutlet UIButton *tagBtn;
	NSString *selectedCity;
	IBOutlet UIButton *cityBtn;
	
	IBOutlet UIButton *nearbyBtn;
	IBOutlet UIButton *filterBtn;
	
	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
	BOOL useCurrentLocation;
}

@property (nonatomic, retain) id <ExploreDelegate> delegate;

@property (nonatomic, retain) IBOutlet UIView *filterView;
@property (assign) BOOL filtering;

@property ExploreMode exploreMode;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *photos;

@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) IBOutlet UIButton *tagBtn;
@property (nonatomic, retain) IBOutlet UIButton *cityBtn;

@property (nonatomic, retain) IBOutlet UIButton *nearbyBtn;
@property (nonatomic, retain) IBOutlet UIButton *filterBtn;

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (IBAction)filterButtonTapped:(id)sender;
- (IBAction)exploreButtonTapped:(id)sender;
- (IBAction)nearbyButtonTapped:(id)sender;
- (void)willLogout;

@end
