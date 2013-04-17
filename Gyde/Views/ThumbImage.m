//
//  ThumbImage.m
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import "ThumbImage.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

#define IMAGE_WIDTH 53.0
#define IMAGE_HEIGHT 53.0

@implementation ThumbImage

- (id)initWithFrame:(CGRect)frame url:(NSString *)_urlString thumbID:(NSString *)tID
{
    self = [super initWithFrame:frame];
    if (self) {
		
		self.thumbID = tID;
		
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
		[polaroidBG setImage:[UIImage imageNamed:@"thumb-slider-polaroid-bg.png"]];
		[self addSubview:polaroidBG];
        
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(7.0, 5.0, IMAGE_WIDTH, IMAGE_HEIGHT)];
		[btn setBackgroundColor:[UIColor blackColor]];
		[btn addTarget:self action:@selector(imageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn setContentMode:UIViewContentModeScaleAspectFill];
		
		self.imageView = btn;
		
		[self addSubview:self.imageView];
		
		// Start downloading image
		[self initImageDownload:_urlString];
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


- (void)initImageDownload:(NSString *)urlString {

	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
		
		[self.imageView setImage:requestedImage forState:UIControlStateNormal];
	}];
	[operation start];
}


- (void)imageButtonClicked:(id)sender {

	[self.delegate thumbTapped:self.thumbID];
}


@end
