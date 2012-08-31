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

@interface TACameraVC ()

@end

@implementation TACameraVC

@synthesize approveBtn, cancelBtn, photo;

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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload {
	
    [photo release];
    self.photo = nil;
	[approveBtn release];
	self.approveBtn = nil;
	[cancelBtn release];
	self.cancelBtn = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [photo release];
	[approveBtn release];
	[cancelBtn release];
    [super dealloc];
}


- (void)viewWillAppear:(BOOL)animated {

	[super viewWillAppear:animated];
	
	// Show camera
	[self showCameraUI:nil];
}


// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
	
    [picker dismissModalViewControllerAnimated:YES];
    [picker release];
}


// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;	
	
	// Handle a still image capture
	if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
		
		editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];		
		originalImage = (UIImage *)[info objectForKey: UIImagePickerControllerOriginalImage];
		
		if (editedImage) imageToSave = editedImage;
		else imageToSave = originalImage;
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
	if (imageURLProcessed && (self.imageReferenceURL != nil) && !self.locationManager.updating) {
		
		// stop the location timer
		[locationTimer invalidate];
		locationTimer = nil;
		
		TAShareVC *shareVC = [[TAShareVC alloc] initWithNibName:@"TAShareVC" bundle:nil];
		[shareVC setPhoto:self.latestImageView.image];
		[shareVC setImageReferenceURL:self.imageReferenceURL];
		
		[self.navigationController pushViewController:shareVC animated:YES];
		[shareVC release];
		
		// Clear the image view, for next it needs to be used.
		[self.photo setImage:nil];
		[self setImageReferenceURL:nil];
	}
	
	else {
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"The metadata for your image has not yet been processed fully. Try again shortly." delegate:nil cancelButtonTitle:@"OK"
										   otherButtonTitles:nil];
		[av show];
		[av release];
	}
}



@end
