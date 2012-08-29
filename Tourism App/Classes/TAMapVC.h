//
//  TAMapVC.h
//  Tourism App
//
//  Created by Richard Lee on 29/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef enum {
	MapModeSingle = 0,
	MapModeMultiple = 1
} MapMode;

@interface TAMapVC : UIViewController {
	
	MapMode mapMode;

	NSDictionary *locationData;
	
	IBOutlet MKMapView *map;
}

@property MapMode mapMode;

@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) NSDictionary *locationData;


@end
