//
//  TACameraVC.m
//  Tourism App
//
//  Created by Richard Lee on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import "TAShareVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyCoreLocation.h"


@interface TACameraVC ()

@end

@implementation TACameraVC

@synthesize approveBtn, cancelBtn, photo, imageReferenceURL;
@synthesize takePhotoBtn, selectPhotoBtn, locationManager, currentLocation;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
	// Get user location
	MyCoreLocation *location = [[MyCoreLocation alloc] init];
	self.locationManager = location;
	[location release];
	
	// We are the delegate for the MyCoreLocation object
	[self.locationManager setCaller:self];
}

- (void)viewDidUnload {
	
	self.currentLocation = nil;
	self.locationManager = nil;
	self.imageReferenceURL = nil;
	
    [photo release];
    self.photo = nil;
	[approveBtn release];
	self.approveBtn = nil;
	[cancelBtn release];
	self.cancelBtn = nil;
	[takePhotoBtn release];
	self.takePhotoBtn = nil;
	[selectPhotoBtn release];
	self.selectPhotoBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
	
	[currentLocation release];
	[imageReferenceURL release];
    [photo release];
	[approveBtn release];
	[cancelBtn release];
	[takePhotoBtn release];
	[selectPhotoBtn release];
    [super dealloc];
}


- (void)viewDidAppear:(BOOL)animated {
	
	// Start the location managing - tell it to start updating, 
	// if it's not already doing so
	[self startLocationManager:nil];
	
    [super viewDidAppear:animated];
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    if (currentLocation) [currentLocation release];
    currentLocation = [loc retain];
	
	// Stop the loading animation
	//[self.loadingSpinner stopAnimating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);

}

- (void)startLocationManager:(id)sender {
	
	// Retrieve the user's current location
	// if the location manager is not already updating the user's location
	if (!self.locationManager.updating) {
		
		//[self.loadingSpinner startAnimating];
		
		NSLog(@"LOCATION MANAGER STARTED");
		
		[self.locationManager startUpdating];
	}
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
	
    [picker dismissModalViewControllerAnimated:YES];
    [picker release];
}


// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
	// We have not yet gotten the URL for this Image file
	imageURLProcessed = NO;
	
	// Hide the take/select buttons
	self.takePhotoBtn.hidden = YES;
	self.selectPhotoBtn.hidden = YES;
	
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;	
	
	// Handle a still image capture
	if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
		
		editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];		
		originalImage = (UIImage *)[info objectForKey: UIImagePickerControllerOriginalImage];
		
		if (editedImage) imageToSave = editedImage;
		else imageToSave = originalImage;
		
		// IF the image was selected from the phone's Photo library
		// then we grab the reference URL from the info dictionary and assign it
		// to the imageReferenceURL property
		if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
			
			selectedPhoto = YES;
			imageURLProcessed = YES;
			self.imageReferenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
			NSLog(@"referenceURL:%@", self.imageReferenceURL);
		}
		
		// If the user just took a photo using the camera
		if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) { 
			
			selectedPhoto = NO;
			
			// Save photo the Photo Library
			//UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo);
			UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
			
			imageURLProcessed = YES;
		}
	}
	
	if (self.photo.image) self.photo.image = nil;
	
	// Display image in our image view
	UIImage *displayImage = [imageToSave copy];
	[self.photo setImage:displayImage];
	[displayImage release];
	
	// Hide the camera UI
    [picker dismissModalViewControllerAnimated:YES];
	
	// Release
    [picker release];
}


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
								   usingDelegate: (id <UIImagePickerControllerDelegate,
												   UINavigationControllerDelegate>) delegate {
	
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
		|| (delegate == nil) || (controller == nil))
        return NO;
	
	
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
	
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
	
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = YES;
    cameraUI.delegate = delegate;
	
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}


#pragma MY METHODS

- (IBAction)showCameraUI:(id)sender {
	
	[self startCameraControllerFromViewController:self usingDelegate:self];
}


- (IBAction)newPhotoApproved:(id)sender {
	
	// Check that: the image URL has been found (processed), the image URL is NOT nil
	// AND the locationManager is NOT currently updating
	if (imageURLProcessed && !self.locationManager.updating) {
		
		// Show the take/select buttons
		self.takePhotoBtn.hidden = NO;
		self.selectPhotoBtn.hidden = NO;
		
		TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
		[shareVC setPhoto:self.photo.image];
		if (selectedPhoto) [shareVC setImageReferenceURL:self.imageReferenceURL];
		else [shareVC setCurrentLocation:self.currentLocation];
		
		[self.navigationController pushViewController:shareVC animated:YES];
		[shareVC release];
		
		// Clear the image view, for next it needs to be used.
		[self.photo setImage:nil];
		[self setImageReferenceURL:nil];
	}
}


- (IBAction)takePhotoButtonTapped:(id)sender {

	[self startCameraControllerFromViewController:self usingDelegate:self];
}


- (IBAction)selectPhotoButtonTapped:(id)sender {

	UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	
	[self presentModalViewController:picker animated:YES];
}


- (IBAction)cancelButtonTapped:(id)sender {

	// Remove the photo from the main image view
	self.photo.image = nil;
	
	// Show the take/select buttons
	self.takePhotoBtn.hidden = NO;
	self.selectPhotoBtn.hidden = NO;
}


- (NSDictionary *)getGPSDictionaryForLocation:(CLLocation *)location {
	
    NSMutableDictionary *gps = [NSMutableDictionary dictionary];
	
    // GPS tag version
    [gps setObject:@"2.2.0.0" forKey:(NSString *)kCGImagePropertyGPSVersion];
	
    // Time and date must be provided as strings, not as an NSDate object
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss.SSSSSS"];
	
	// Is timezone really necessary?
    //[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    //[gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSTimeStamp];
	
    [formatter setDateFormat:@"yyyy:MM:dd"];
    [gps setObject:[formatter stringFromDate:location.timestamp] forKey:(NSString *)kCGImagePropertyGPSDateStamp];
    [formatter release];
	
    // LATITUDE
    CGFloat latitude = location.coordinate.latitude;
	
    if (latitude < 0) {
        latitude = -latitude;
        [gps setObject:@"S" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
    } 
	
	else [gps setObject:@"N" forKey:(NSString *)kCGImagePropertyGPSLatitudeRef];
	
    [gps setObject:[NSNumber numberWithFloat:latitude] forKey:(NSString *)kCGImagePropertyGPSLatitude];
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // LONGITUDE
    CGFloat longitude = location.coordinate.longitude;
	
    if (longitude < 0) {
        longitude = -longitude;
        [gps setObject:@"W" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
    } 
	
	else [gps setObject:@"E" forKey:(NSString *)kCGImagePropertyGPSLongitudeRef];
	
    [gps setObject:[NSNumber numberWithFloat:longitude] forKey:(NSString *)kCGImagePropertyGPSLongitude];
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // ALTITUDE
    CGFloat altitude = location.altitude;
	
    if (!isnan(altitude)){
		
        if (altitude < 0) {
            altitude = -altitude;
            [gps setObject:@"1" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
        } 
		
		else [gps setObject:@"0" forKey:(NSString *)kCGImagePropertyGPSAltitudeRef];
		
        [gps setObject:[NSNumber numberWithFloat:altitude] forKey:(NSString *)kCGImagePropertyGPSAltitude];
    }
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////////
	
    // Speed, must be converted from m/s to km/h
    if (location.speed >= 0){
        [gps setObject:@"K" forKey:(NSString *)kCGImagePropertyGPSSpeedRef];
        [gps setObject:[NSNumber numberWithFloat:location.speed*3.6] forKey:(NSString *)kCGImagePropertyGPSSpeed];
    }
	
    // Heading
    if (location.course >= 0){
        [gps setObject:@"T" forKey:(NSString *)kCGImagePropertyGPSTrackRef];
        [gps setObject:[NSNumber numberWithFloat:location.course] forKey:(NSString *)kCGImagePropertyGPSTrack];
    }
	
    return gps;
}



@end
