//
//  TACommentView.h
//  Tourism App
//
//  Created by Richard Lee on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CommentViewDelegate

- (void)commentReadyForSubmit:(NSString *)commentText;

@end


@interface TACommentView : UIView <UITextViewDelegate> {

	id <CommentViewDelegate> delegate;
	
	UITextView *commentField;
}

@property (nonatomic, retain) id <CommentViewDelegate> delegate;

@property (nonatomic, retain) UITextView *commentField;

@end
