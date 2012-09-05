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

@interface TAExploreVC : UIViewController <TagsDelegate, CitiesDelegate> {
	
	Tag *selectedTag;
	IBOutlet UIButton *tagBtn;
	NSDictionary *selectedCity;
	IBOutlet UIButton *cityBtn;
	
	IBOutlet UIButton *nearbyBtn;
	
	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
	BOOL useCurrentLocation;
}

@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSDictionary *selectedCity;
@property (nonatomic, retain) IBOutlet UIButton *tagBtn;
@property (nonatomic, retain) IBOutlet UIButton *cityBtn;

@property (nonatomic, retain) IBOutlet UIButton *nearbyBtn;

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (IBAction)exploreButtonTapped:(id)sender;
- (IBAction)nearbyButtonTapped:(id)sender;
- (void)willLogout;

@end
