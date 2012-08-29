//
//  MyMapAnnotation.h
//  ATM Locator
//
//  Created by Richard Lee on 12/10/09.
//  Copyright 2009 C2 Media Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface MyMapAnnotation : NSObject <MKAnnotation> {
	
	CLLocationCoordinate2D	coordinate;
	NSString				*_title;
	NSString				*_userData;
	NSURL					*_url;
	NSString				*locationAddress;
	NSNumber				*locationID;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)title;

@property (nonatomic,readwrite,assign) CLLocationCoordinate2D   coordinate;

@property (nonatomic, retain) NSString *userData;
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *locationAddress;
@property (nonatomic, retain) NSNumber *locationID;


@end
