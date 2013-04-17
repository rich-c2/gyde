//
//  GydeScrollViewController.h
//  Gyde
//
//  Created by Richard Lee on 12/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GydeScrollViewController : UIViewController <UIScrollViewDelegate, UITextFieldDelegate>

- (void)applyInputStyleToView:(UIView *)view;

@property (assign, nonatomic) BOOL manuallySetScrollViewDelegate;
@property (assign, nonatomic) BOOL useFullScreenAsScrollViewContentSize;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *contentView;

@property (assign, nonatomic) BOOL keyboardShown;


@end
