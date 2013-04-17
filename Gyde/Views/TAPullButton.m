//
//  TAPullButton.m
//  Tourism App
//
//  Created by Richard Lee on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPullButton.h"

@implementation TAPullButton

@synthesize containerView, delegate, lastTouch, touch, initialTouch;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		lastTouch = 9999.0;
		
		CGRect ribbonFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
		UIImageView *ribbon = [[UIImageView alloc] initWithFrame:ribbonFrame];
		[ribbon setImage:[UIImage imageNamed:@"pull-down-ribbon.png"]];
		[ribbon setUserInteractionEnabled:YES];
		[self addSubview:ribbon];
		
        CGRect btnFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
		UIView *bv = [[UIView alloc] initWithFrame:btnFrame];
		[bv setBackgroundColor:[UIColor clearColor]];
		self.containerView = bv;
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
	
	UITouch *newTouch = [[event allTouches] anyObject];
	CGPoint location = [newTouch locationInView:[[[self superview] superview] superview]];
	//CGPoint xLocation = CGPointMake(location.x, location.y);
	
	initialTouch = location.y;
	
	[self.delegate buttonTouched];
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	touch = [[event allTouches] anyObject];
	CGPoint pointMoved = [touch locationInView:[self superview]];
	
	NSLog(@"pointMoved LOC:%.2f", pointMoved.y);
	
	if (lastTouch != 9999.0) {
		
		[self.delegate buttonPulledToPoint:pointMoved.y];
	}
	
	lastTouch = pointMoved.y;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	UITouch *finalTouch = [[event allTouches] anyObject];
	CGPoint location = [finalTouch locationInView:[[[self superview] superview] superview]];
	//CGPoint xLocation = CGPointMake(location.x, location.y);
	
	if (location.y - initialTouch > 0) pullingUp = NO;
	else pullingUp = YES;
	
	NSLog(@"X LOC:%.2f|%.2f", location.y, initialTouch);
	NSLog(@"PULLING %@", ((pullingUp) ? @"UP" : @"NO"));
	
	//touch = [[event allTouches] anyObject];
	CGPoint pointMoved = [finalTouch locationInView:[self superview]];
	
	[self.delegate pullDownEnded:pointMoved.y pullingUpward:pullingUp];
	
	lastTouch = 9999.0;
}

@end
