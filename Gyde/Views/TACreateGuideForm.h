//
//  TACreateGuideForm.h
//  Tourism App
//
//  Created by Richard Lee on 26/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CreateGuideFormDelegate 

- (void)createGuide:(NSString *)title privateGuide:(BOOL)privateGuide;

@end

@interface TACreateGuideForm : UIView <UITextFieldDelegate> {

	id <CreateGuideFormDelegate> delegate;
	
	UITextField *titleField;
	BOOL isPrivate;
}

@property (nonatomic, retain) id <CreateGuideFormDelegate> delegate;

@property (nonatomic, retain) UITextField *titleField;
@property (assign) BOOL isPrivate;

- (id)initWithFrame:(CGRect)frame city:(NSString *)city tag:(NSString *)tagTitle;

@end
