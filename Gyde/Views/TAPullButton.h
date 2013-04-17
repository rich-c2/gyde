//
//  TAPullButton.h
//  Tourism App
//
//  Created by Richard Lee on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PullButtonDelegate 

- (void)buttonTouched;
- (void)buttonPulledDown:(CGFloat)shift;
- (void)buttonPulledToPoint:(CGFloat)yPos;
- (void)pullDownEnded:(CGFloat)lastYPos pullingUpward:(BOOL)pullingUpward;

@end

@interface TAPullButton : UIView {
	
	id <PullButtonDelegate> delegate;

	BOOL pullingUp;
	
	UIView *containerView;
	
	CGFloat initialTouch;
	CGFloat lastTouch;
	UITouch *touch;
}

@property (nonatomic, retain) id <PullButtonDelegate> delegate;

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic) CGFloat initialTouch;
@property (nonatomic) CGFloat lastTouch;
@property (nonatomic, retain) UITouch *touch;

@end
