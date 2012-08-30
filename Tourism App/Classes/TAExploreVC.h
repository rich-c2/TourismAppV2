//
//  TAExploreVC.h
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TASimpleListVC.h"
#import "TACitiesListVC.h"

@class Tag;

@interface TAExploreVC : UIViewController <TagsDelegate, LocationsDelegate> {
	
	Tag *selectedTag;
	IBOutlet UIButton *tagBtn;
	NSDictionary *selectedCity;
	IBOutlet UIButton *cityBtn;
}

@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) NSDictionary *selectedCity;
@property (nonatomic, retain) IBOutlet UIButton *tagBtn;
@property (nonatomic, retain) IBOutlet UIButton *cityBtn;

- (IBAction)exploreButtonTapped:(id)sender;

@end
