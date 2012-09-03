//
//  TAShareVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TASimpleListVC.h"
#import "CoreLocation/CoreLocation.h"
#import "TAUsersVC.h"
#import <MapKit/MapKit.h>
#import "TAPlacesVC.h"


@class Tag;
@class JSONFetcher;
@class XMLFetcher;

@interface TAShareVC : UIViewController <TagsDelegate, RecommendsDelegate, PlacesDelegate> {
	
	// Was the submission of the photo successful?
	BOOL submissionSuccess;
	
	// UI
	IBOutlet UITextField *captionField;
	IBOutlet UIButton *tagBtn;
	IBOutlet UILabel *cityLabel;
	IBOutlet MKMapView *map;
	
	JSONFetcher *submitFetcher;
	XMLFetcher *cityFetcher;
	
	NSString *selectedCity;
	Tag *selectedTag;
	NSMutableArray *recommendToUsernames;
	NSMutableDictionary *placeData;

	UIImage *photo;
	NSURL *imageReferenceURL;
	
	CLLocation *currentLocation;
}

@property (nonatomic, retain) IBOutlet UITextField *captionField;
@property (nonatomic, retain) IBOutlet UIButton *tagBtn;
@property (nonatomic, retain) IBOutlet UILabel *cityLabel;
@property (nonatomic, retain) IBOutlet MKMapView *map;

@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSMutableArray *recommendToUsernames;
@property (nonatomic, retain) NSMutableDictionary *placeData;

@property (nonatomic, retain) UIImage *photo;
@property (nonatomic, retain) NSURL *imageReferenceURL;

@property (nonatomic, retain) CLLocation *currentLocation;


@end
