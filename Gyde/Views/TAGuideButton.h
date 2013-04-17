//
//  TAGuideButton.h
//  Tourism App
//
//  Created by Richard Lee on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuideButtonDelegate <NSObject>

- (void)selectedGuide:(NSString *)guideID;

@end

@interface TAGuideButton : UIView {

	id <GuideButtonDelegate> delegate;
	
	NSString *guideID;
	UIImageView *thumbView;
}

@property (nonatomic, retain) id <GuideButtonDelegate> delegate;

@property (nonatomic, retain) NSString *guideID;
@property (nonatomic, retain) UIImageView *thumbView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title loves:(NSString *)loves thumbURL:(NSString *)urlString;


@end
