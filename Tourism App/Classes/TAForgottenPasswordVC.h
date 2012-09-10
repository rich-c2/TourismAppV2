//
//  TAForgottenPasswordVC.h
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JSONFetcher;

@interface TAForgottenPasswordVC : UIViewController {
	
	JSONFetcher *sendPasswordfetcher;
	
	IBOutlet UITextField *usernameField;
}

@property (nonatomic, retain) IBOutlet UITextField *usernameField;

@end
