//
//  TAGuideButton.m
//  Tourism App
//
//  Created by Richard Lee on 25/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAGuideButton.h"
#import "StringHelper.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

@implementation TAGuideButton

@synthesize guideID, delegate, thumbView;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title loves:(NSString *)loves thumbURL:(NSString *)urlString {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        
		CGRect guideBtnFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
		UIButton *guideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[guideBtn setFrame:guideBtnFrame];
		[guideBtn setImage:[UIImage imageNamed:@"guide-button.png"] forState:UIControlStateNormal];
		[guideBtn setImage:[UIImage imageNamed:@"guide-button-on.png"] forState:UIControlStateHighlighted];
		[guideBtn setImage:[UIImage imageNamed:@"guide-button-on.png"] forState:UIControlStateSelected];
		
		[guideBtn addTarget:self action:@selector(guideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];	
		[self addSubview:guideBtn];
		
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 7.0, 372.0, 16.0)];
		[titleLabel setText:title];
		[titleLabel setFont:[UIFont systemFontOfSize:15.0]];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:80.0/255.0 alpha:1.0]];
		[self addSubview:titleLabel];
		
		UILabel *lovesLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 24.0, 372.0, 14.0)];
		[lovesLabel setText:[NSString stringWithFormat:@"%@ loves", loves]];
		[lovesLabel setFont:[UIFont systemFontOfSize:12.0]];
		[lovesLabel setBackgroundColor:[UIColor clearColor]];
		[lovesLabel setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
		[self addSubview:lovesLabel];
		
		UIImageView *tv = [[UIImageView alloc] initWithFrame:CGRectMake(9.0, 9.0, 30.0, 30.0)];
		[tv setBackgroundColor:[UIColor blackColor]];
		
		self.thumbView = tv;
		
		[self addSubview:self.thumbView];
		
		// Start image thumb download
		[self initImageDownload:urlString];
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


- (void)guideButtonTapped:(id)sender {

	[self.delegate selectedGuide:self.guideID];
}


- (void)initImageDownload:(NSString *)urlString {

	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
		
		[self.thumbView setImage:requestedImage];
	}];
	[operation start];
}



@end
