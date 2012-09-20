//
//  TARegisterVC.h
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TARegisterVC : UIViewController {
	
	JSONFetcher *registerFetcher;

	IBOutlet UIScrollView *formScrollView;
	IBOutlet UITextField *nameField;
	IBOutlet UITextField *emailField;
	IBOutlet UITextField *usernameField;
	IBOutlet UITextField *passwordField;
}

@property (nonatomic, retain) IBOutlet UIScrollView *formScrollView;
@property (nonatomic, retain) IBOutlet UITextField *nameField;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;

- (IBAction)goBack:(id)sender;



@end
