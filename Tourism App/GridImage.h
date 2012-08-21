//
//  GridImage.h
//  GiftHype
//
//  Created by Richard Lee on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridImageDelegate

- (void)gridImageButtonClicked:(NSInteger)viewTag;

@end

@interface GridImage : UIView {
	
	id <GridImageDelegate> delegate;
	
	BOOL selected;
	BOOL editMode;

	UIButton *imageView;
	NSURL* imageURL;
}

@property (nonatomic, retain) id <GridImageDelegate> delegate;

@property (nonatomic, retain) UIButton *imageView;
@property (nonatomic, retain) NSURL* imageURL;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString;
- (void)initImage:(NSString *)urlString;
- (void)editing;
- (void)select;
- (void)deselect;

@end
