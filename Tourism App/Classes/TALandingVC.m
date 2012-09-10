//
//  TALandingVC.m
//  Tourism App
//
//  Created by Richard Lee on 10/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TALandingVC.h"
#import "TALoginVC.h"
#import "TARegisterVC.h"

@interface TALandingVC ()

@end

@implementation TALandingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma MY METHODS

- (IBAction)loginButtonTapped:(id)sender {

	TALoginVC *loginVC = [[TALoginVC alloc] initWithNibName:@"TALoginVC" bundle:nil];
	
	[self.navigationController pushViewController:loginVC animated:YES];
	[loginVC release];
}

- (IBAction)signUpButtonTapped:(id)sender {

	TARegisterVC *registerVC = [[TARegisterVC alloc] initWithNibName:@"TARegisterVC" bundle:nil];
	
	[self.navigationController pushViewController:registerVC animated:YES];
	[registerVC release];
}



@end
