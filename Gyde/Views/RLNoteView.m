//
//  RLNoteView.m
//  Gyde
//
//  Created by Richard Lee on 6/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import "RLNoteView.h"

#define ANIMATION_DURATION 0.5

@implementation RLNoteView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showTipViewWithAnimation:(BOOL)animate
                 completionBlock:(void(^)(BOOL finished))completionBlock {
    
    CGFloat yPos = CGRectGetMinY(self.superview.frame);
    CGRect newFrame = self.frame;
    newFrame.origin.y = yPos;
    
    if (!animate) {
        
        self.frame = newFrame;
        completionBlock(YES);
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0
                        options:(UIViewAnimationCurveEaseIn)
                     animations:^{
                         
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                   
                       completionBlock(YES);
                   }];
}

- (void)hideTipViewWithAnimation:(BOOL)animate
                 completionBlock:(void(^)(BOOL finished))completionBlock {
    
    CGFloat yPos = CGRectGetMinY(self.superview.frame) - self.frame.size.height;
    NSLog(@"POS:%f", yPos);
    CGRect newFrame = self.frame;
    newFrame.origin.y = yPos;
    
    if (!animate) {
        
        self.frame = newFrame;
        completionBlock(YES);
    }
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:0
                        options:(UIViewAnimationCurveEaseOut)
                     animations:^{
                         
                         self.frame = newFrame;
                     }
                     completion:^(BOOL finished){
                         
                         completionBlock(YES);
                     }];
}


@end
