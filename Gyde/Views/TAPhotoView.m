//
//  TAPhotoView.m
//  Tourism App
//
//  Created by Richard Lee on 21/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPhotoView.h"

@implementation TAPhotoView

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
	
    if (self) {
       
		[self setUserInteractionEnabled:YES];
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


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch *t = [[event allTouches] anyObject];
    NSUInteger tapCount = [t tapCount];
    
    switch (tapCount) {
            
        case 1: {
            [self performSelector:@selector(singleTap) withObject:nil afterDelay:.3];
            break;
        }
        case 2:
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            [self performSelector:@selector(doubleTap) withObject:nil afterDelay:.3];
            break;
        default:
            break;
    }
}

- (void)singleTap {
	
	//lastTouch = yVal;
	//NSLog(@"SINGLE!");
}

- (void)doubleTap {
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Loved Photo" message:@"You LOVED this photo" delegate:self cancelButtonTitle:@"Cheers!" otherButtonTitles:nil, nil];
	[av show];
}


@end
