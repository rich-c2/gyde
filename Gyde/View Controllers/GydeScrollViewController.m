//
//  GydeScrollViewController.m
//  Gyde
//
//  Created by Richard Lee on 12/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "GydeScrollViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface GydeScrollViewController ()

@end

@implementation GydeScrollViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
    [self setContentView:nil];
    [self setScrollView:nil];
    [self viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Handling keyboard showing / hiding (should only listen
    // once the view is loaded)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate;
{
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Setting initial height of scroll view
    if (self.contentView.bounds.size.height <= self.scrollView.bounds.size.height) {
        CGSize contentSize = self.scrollView.bounds.size;
        contentSize.height += 1;
        self.scrollView.contentSize = contentSize;
    } else {
        self.scrollView.contentSize = self.contentView.bounds.size;
    }
    
    // Setting up scroll view delegate
    if (!self.manuallySetScrollViewDelegate) {
        UIScrollView *scrollView = (UIScrollView *)self.view;
        scrollView.delegate = self;
    }
    
    [self.scrollView flashScrollIndicators];
}

- (CGSize)_getScrollViewContentSizeNavbarHidden:(BOOL)navbarHidden {
    NSInteger width;
    NSInteger height;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        width = [UIScreen mainScreen].applicationFrame.size.width;
        height = [UIScreen mainScreen].applicationFrame.size.height + 1;
    } else {
        width = [UIScreen mainScreen].applicationFrame.size.height;
        height = [UIScreen mainScreen].applicationFrame.size.width + 1;
    }
    
    if (!navbarHidden) {
        height -= 44;
    }
    
    return CGSizeMake(width , height);
}

#pragma mark - Hiding / showing keyboard

- (void)_keyboardWillShow:(NSNotification *)note {
    CGFloat        keyboardHeight    = [self _getKeyboardHeightFromKeyboardNotification:note];
    NSTimeInterval animationDuration = [self _getKeyboardAnimationDurationForNotification:note];
    
    if (keyboardHeight == 0) {
        return;
    }
    
    if (self.keyboardShown && !self.useFullScreenAsScrollViewContentSize) {
        // If using full screen as scroll view content size, then always resize
        // regardless of whether the keyboard is shown or not
        return;
    }
    
    self.keyboardShown = YES;
    
    [UIView animateWithDuration:animationDuration animations:^{
        // Adjusting scroll view size
        if (self.useFullScreenAsScrollViewContentSize) {
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.size = [self _getScrollViewContentSizeNavbarHidden:NO];
            scrollViewFrame.size.height -= keyboardHeight;
            self.scrollView.frame = scrollViewFrame;
            
        } else {
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.size.height -= keyboardHeight;
            self.scrollView.frame = scrollViewFrame;
        }
        
        // Adjusting content size to match scroll view size
        // Note: Will pick whatever height is largest, to ensure the user
        // will always be able to "bounce scroll" the view
        CGSize contentViewSize = self.contentView.bounds.size;
        contentViewSize.height = MAX(self.scrollView.bounds.size.height + 1, self.contentView.bounds.size.height);
        self.scrollView.contentSize = contentViewSize;
    }];
}

- (void)_keyboardWillHide:(NSNotification *)note {
    CGFloat        keyboardHeight    = [self _getKeyboardHeightFromKeyboardNotification:note];
    NSTimeInterval animationDuration = [self _getKeyboardAnimationDurationForNotification:note];
    
    if (keyboardHeight == 0) {
        return;
    }
    
    if (!self.keyboardShown && !self.useFullScreenAsScrollViewContentSize) {
        // If using full screen as scroll view content size, then always resize
        // regardless of whether the keyboard is shown or not
        return;
    }
    
    self.keyboardShown = NO;
    
    [UIView animateWithDuration:animationDuration animations:^{
        // Adjusting scroll view size
        if (self.useFullScreenAsScrollViewContentSize) {
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.size = [self _getScrollViewContentSizeNavbarHidden:NO];
            self.scrollView.frame = scrollViewFrame;
            
        } else {
            CGRect scrollViewFrame = self.scrollView.frame;
            scrollViewFrame.size.height += keyboardHeight;
            self.scrollView.frame = scrollViewFrame;
        }
        
        // Adjusting content size to match scroll view size
        // Note: Will pick whatever height is largest, to ensure the user
        // will always be able to "bounce scroll" the view
        CGSize contentViewSize = self.contentView.bounds.size;
        contentViewSize.height = MAX(self.scrollView.bounds.size.height + 1, self.contentView.bounds.size.height);
        self.scrollView.contentSize = contentViewSize;
    }];
}

- (NSInteger)_getKeyboardHeightFromKeyboardNotification:(NSNotification *)notification {
	// When in landscape, keyboard height is labelled "width"
	CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
	return keyboardBounds.size.height > keyboardBounds.size.width ? keyboardBounds.size.width : keyboardBounds.size.height;
}

- (NSTimeInterval)_getKeyboardAnimationDurationForNotification:(NSNotification*)notification {
    NSTimeInterval duration;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
    return duration;
}

#pragma mark - Formatting

- (void)applyInputStyleToView:(UIView *)view {
    view.layer.cornerRadius = 4;
    view.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    view.layer.borderWidth = 1;
    view.layer.shouldRasterize = YES;
    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
}

@end
