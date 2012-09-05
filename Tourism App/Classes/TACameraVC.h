//
//  TACameraVC.h
//  Tourism App
//
//  Created by Richard Lee on 31/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"


@class MyCoreLocation;

@interface TACameraVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

	MyCoreLocation *locationManager;
	CLLocation *currentLocation;
	
	BOOL selectedPhoto;
	
	BOOL imageURLProcessed;
	NSURL *imageReferenceURL;
	
	IBOutlet UIButton *takePhotoBtn;
	IBOutlet UIButton *selectPhotoBtn;
	
	
	IBOutlet UIButton *cancelBtn;
	IBOutlet UIButton *approveBtn;
	IBOutlet UIImageView *photo;
}

@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

@property (nonatomic, retain) NSURL *imageReferenceURL;

@property (nonatomic, retain) IBOutlet UIButton *takePhotoBtn;
@property (nonatomic, retain) IBOutlet UIButton *selectPhotoBtn;

@property (nonatomic, retain) IBOutlet UIButton *cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton *approveBtn;
@property (nonatomic, retain) IBOutlet UIImageView *photo;

- (IBAction)newPhotoApproved:(id)sender;
- (void)willLogout;

@end
