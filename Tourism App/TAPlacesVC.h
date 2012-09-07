//
//  TAPlacesVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"


@class JSONFetcher;

@protocol PlacesDelegate

@optional

- (void)placeSelected:(NSMutableDictionary *)placeData;

- (void)locationMapped:(CLLocation *)newLocation;

@end

@interface TAPlacesVC : UIViewController {
	
	id <PlacesDelegate> delegate;
	
	BOOL loading;
	BOOL venuesLoaded;

	JSONFetcher *venuesFetcher;
	
	NSMutableArray *places;
	NSNumber *latitude;
	NSNumber *longitude;
	
	IBOutlet UITableView *placesTable;
	IBOutlet UIButton *mapItBtn;
}

@property (nonatomic, retain) id <PlacesDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *places;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;

@property (nonatomic, retain) IBOutlet UITableView *placesTable;
@property (nonatomic, retain) IBOutlet UIButton *mapItBtn;

- (IBAction)mapItButtonTapped:(id)sender;

@end
