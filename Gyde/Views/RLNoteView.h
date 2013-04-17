//
//  RLNoteView.h
//  Gyde
//
//  Created by Richard Lee on 6/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLNoteView : UIView

@property (nonatomic, strong) IBOutlet UIView *contentView;

- (void)showTipViewWithAnimation:(BOOL)animate
                 completionBlock:(void(^)(BOOL finished))completionBlock;
- (void)hideTipViewWithAnimation:(BOOL)animate
                 completionBlock:(void(^)(BOOL finished))completionBlock;

@end
