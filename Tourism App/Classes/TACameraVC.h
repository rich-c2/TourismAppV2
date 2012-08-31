//
//  TACameraVC.h
//  Tourism App
//
//  Created by Richard Lee on 31/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TACameraVC : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

	IBOutlet UIButton *cancelBtn;
	IBOutlet UIButton *approveBtn;
	IBOutlet UIImageView *photo;
}

@property (nonatomic, retain) IBOutlet UIButton *cancelBtn;
@property (nonatomic, retain) IBOutlet UIButton *approveBtn;
@property (nonatomic, retain) IBOutlet UIImageView *photo;

- (IBAction)newPhotoApproved:(id)sender;

@end
