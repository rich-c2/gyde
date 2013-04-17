//
//  GridImage.m
//  GiftHype
//
//  Created by Richard Lee on 24/11/11.
//  Copyright (c) 2011 C2 Media Pty Ltd. All rights reserved.
//

#import "GridImage.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

#define TICK_MARK_VIEW_TAG 9000
#define CLOSE_VIEW_TAG 8000
#define IMAGE_WIDTH 83.0
#define IMAGE_HEIGHT 83.0

@implementation GridImage

@synthesize imageView, delegate;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[polaroidBG setImage:[UIImage imageNamed:@"thumb-polaroid-bg.png"]];
		[self addSubview:polaroidBG];
		
        
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(10.0, 10.0, IMAGE_WIDTH, IMAGE_HEIGHT)];
		[btn setBackgroundColor:[UIColor blackColor]];
		[btn addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn setContentMode:UIViewContentModeScaleAspectFill];
		
		self.imageView = btn;
		
		[self addSubview:self.imageView];
		
		// Start downloading image
		[self initImage:imageURLString];
    }
	
    return self;
}


- (void)initImage:(NSString *)urlString {
	
	if (urlString) {

        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
            
            [self.imageView setImage:requestedImage forState:UIControlStateNormal];
        }];
        [operation start];
    }
}


- (void)imageButtonClicked:(id)sender {

    if ([(NSObject *)self.delegate respondsToSelector:@selector(gridImageButtonClicked:)])
        [self.delegate gridImageButtonClicked:self.tag];
    else
        [self.delegate gridImageButtonTapped:self];
}



@end
