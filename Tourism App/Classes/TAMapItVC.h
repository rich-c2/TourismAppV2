//
//  TAMapItVC.h
//  Tourism App
//
//  Created by Richard Lee on 3/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TAPlacesVC.h"


@interface TAMapItVC : UIViewController {

	id <PlacesDelegate> delegate;
	
	IBOutlet MKMapView *map;
	CLLocation *currentLocation;
}

@property (nonatomic, retain) id <PlacesDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *map;
@property (nonatomic, retain) CLLocation *currentLocation;


@end
