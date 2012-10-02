//
//  EditProfileVC.h
//  GiftHype
//
//  Created by Richard Lee on 15/05/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TACitiesListVC.h"

@class JSONFetcher;

@interface EditProfileVC : UIViewController <CitiesDelegate> {

	NSManagedObjectContext *managedObjectContext;
	
	BOOL loading;
	BOOL profileLoaded;
	
	JSONFetcher *updateProfileFetcher;
	JSONFetcher *profileFetcher;
	
	UITextView *bioView;
	UITextField *firstNameField, *lastNameField, *emailField;
	UITextField *currentTextField;
	
	UIImageView *avatarView;
	
	NSString *selectedCity;
	IBOutlet UIButton *cityBtn;
	
	UIScrollView *formScrollView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet UITextView *bioView;
@property (nonatomic, retain) IBOutlet UITextField *firstNameField; 
@property (nonatomic, retain) IBOutlet UITextField *lastNameField; 
@property (nonatomic, retain) IBOutlet UITextField *emailField; 
@property (nonatomic, retain) UITextField *currentTextField;

@property (nonatomic, retain) UIImageView *avatarView;

@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) IBOutlet UIButton *cityBtn;

@property (nonatomic, retain) IBOutlet UIScrollView *formScrollView;

- (IBAction)saveButtonTapped:(id)sender;
- (void)willLogout;
- (IBAction)selectCityButtonTapped:(id)sender;

@end
