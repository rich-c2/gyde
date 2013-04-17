//
//  TACommentView.m
//  Tourism App
//
//  Created by Richard Lee on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TACommentView.h"

#define SIDE_PADDING 14.0
#define TOP_PADDING 14.0
#define COMMENT_FIELD_WIDTH 256.0

@implementation TACommentView

@synthesize commentField, delegate;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		// SHADOW AND ROUNDED CORNERS
		CGRect leftShadowFrame = CGRectMake(SIDE_PADDING, 10.0, 9.0, 185.0);
		UIImageView *leftShadow = [[UIImageView alloc] initWithFrame:leftShadowFrame];
		[leftShadow setImage:[UIImage imageNamed:@"left-comment-field-shadow.png"]];
		[self addSubview:leftShadow];
		
		
		// SHADOW AND ROUNDED CORNERS
		CGRect rightShadowFrame = CGRectMake((SIDE_PADDING + leftShadowFrame.size.width + COMMENT_FIELD_WIDTH), 10.0, 9.0, 185.0);
		UIImageView *rightShadow = [[UIImageView alloc] initWithFrame:rightShadowFrame];
		[rightShadow setImage:[UIImage imageNamed:@"right-comment-field-shadow.png"]];
		[self addSubview:rightShadow];
		
		
		CGRect whiteFrame = CGRectMake((SIDE_PADDING + leftShadowFrame.size.width), 10.0, COMMENT_FIELD_WIDTH, TOP_PADDING);
		UIView *whiteView = [[UIView alloc] initWithFrame:whiteFrame];
		[whiteView setBackgroundColor:[UIColor whiteColor]];
		[self addSubview:whiteView];
		
        
		// TEXT VIEW FOR ADDING COMMENT
		CGRect fieldFrame = CGRectMake((SIDE_PADDING + leftShadowFrame.size.width), (10.0 + TOP_PADDING), COMMENT_FIELD_WIDTH, 156.0);
		UITextView *cf = [[UITextView alloc] initWithFrame:fieldFrame];
		[cf setDelegate:self];
		[cf setReturnKeyType:UIReturnKeyDone];
		[cf becomeFirstResponder];
		
		self.commentField = cf;
		
		
		// BOTTOM SHADOW
		CGRect bottomShadowFrame = CGRectMake((SIDE_PADDING + leftShadowFrame.size.width), ((10.0 + TOP_PADDING) + fieldFrame.size.height), 256.0, 15.0);
		UIImageView *bottomShadow = [[UIImageView alloc] initWithFrame:bottomShadowFrame];
		[bottomShadow setImage:[UIImage imageNamed:@"bottom-comment-field-shadow.png"]];
		[self addSubview:bottomShadow];
		
		[self addSubview:commentField];
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


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {  
	
	BOOL shouldChangeText = YES; 
	
	if ([text isEqualToString:@"\n"]) {  
		
		shouldChangeText = NO;
		
		// Hide the keyboard
		[textView resignFirstResponder];  
		
		// Tell the delegate that the return button
		// has been tapped and pass the comment
		// text to the delegate
		[self.delegate commentReadyForSubmit:self.commentField.text];
	}  
	
	return shouldChangeText;  
}


@end
