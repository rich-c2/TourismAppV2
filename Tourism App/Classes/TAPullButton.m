//
//  TAPullButton.m
//  Tourism App
//
//  Created by Richard Lee on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPullButton.h"

@implementation TAPullButton

@synthesize containerView, delegate, lastTouch, touch;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		lastTouch = 999.0;
		
        CGRect btnFrame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
		UIView *bv = [[UIView alloc] initWithFrame:btnFrame];
		[bv setBackgroundColor:[UIColor cyanColor]];
		self.containerView = bv;
		[bv release];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	//NSLog(@"TOUCHES BEGAN");
	
	[self.delegate buttonTouched];
	
	/*
	UITouch *touch = (UITouch *)[touches anyObject];
	start = [touch locationInView:self.superview].y;
	if(start > 30 && pulldownView.center.y < 0)//touch was not in upper area of view AND pulldownView not visible
	{
		start = -1; //start is a CGFloat member of this view
	}*/
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
	touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView:touch.view];
	CGPoint xLocation = CGPointMake(location.x, location.y);
	//NSLog(@"Hey:%f", xLocation.y);	
	
	CGPoint pointMoved = [touch locationInView:[self superview]];
	
	if (lastTouch != 999.0) {
	
		//CGFloat touchShift = lastTouch - xLocation.y;
		
		/*CGRect newFrame = self.frame;
		newFrame.origin.y = pointMoved.y;
		
		[self setFrame:newFrame];*/
		
		//[self.delegate buttonPulledDown:touchShift];
		
		[self.delegate buttonPulledToPoint:pointMoved.y];
		
		if (xLocation.y > lastTouch) pullingUp = NO;
		else pullingUp = YES;
	}
	
	lastTouch = xLocation.y;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	/*UITouch *finalTouch = [[event allTouches] anyObject];
	CGPoint location = [finalTouch locationInView:touch.view];
	CGPoint xLocation = CGPointMake(location.x, location.y);
	
	if (xLocation.y > lastTouch) pullingUp = NO;
	else pullingUp = YES;*/
	
	touch = [[event allTouches] anyObject];
	CGPoint pointMoved = [touch locationInView:[self superview]];
	
	[self.delegate pullDownEnded:pointMoved.y pullingUpward:pullingUp];
	
	//lastTouch = 999.0;
}

@end
