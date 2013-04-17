//
//  GridImage.h
//  GiftHype
//
//  Created by Richard Lee on 24/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GridImageDelegate

@optional
- (void)gridImageButtonClicked:(NSInteger)viewTag;
- (void)gridImageButtonTapped:(id)sender;

@end

@interface GridImage : UIView {
	
	id <GridImageDelegate> delegate;

	UIButton *imageView;
}

@property (nonatomic, retain) id <GridImageDelegate> delegate;

@property (nonatomic, retain) UIButton *imageView;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString;
- (void)initImage:(NSString *)urlString;

@end
