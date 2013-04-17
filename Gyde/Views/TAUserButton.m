//
//  TAUserButton.m
//  Tourism App
//
//  Created by Richard Lee on 8/10/12.
//
//

#import "TAUserButton.h"
#import "StringHelper.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

@implementation TAUserButton

@synthesize username, thumbView, delegate;

- (id)initWithFrame:(CGRect)frame user:(NSString *)buttonUsername
			   name:(NSString *)name thumbURL:(NSString *)urlString {
	
    self = [super initWithFrame:frame];
	
    if (self) {
		
		self.username = buttonUsername;
        
		CGRect userBtnFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
		UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[userBtn setFrame:userBtnFrame];
		[userBtn setImage:[UIImage imageNamed:@"guide-button.png"] forState:UIControlStateNormal];
		[userBtn setImage:[UIImage imageNamed:@"guide-button-on.png"] forState:UIControlStateHighlighted];
		[userBtn setImage:[UIImage imageNamed:@"guide-button-on.png"] forState:UIControlStateSelected];
		[userBtn setImage:[UIImage imageNamed:@"guide-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
		
		[userBtn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:userBtn];
		
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 7.0, 372.0, 16.0)];
		[usernameLabel setText:buttonUsername];
		[usernameLabel setFont:[UIFont systemFontOfSize:15.0]];
		[usernameLabel setBackgroundColor:[UIColor clearColor]];
		[usernameLabel setTextColor:[UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:80.0/255.0 alpha:1.0]];
		[self addSubview:usernameLabel];
		
		UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47.0, 24.0, 372.0, 14.0)];
		[nameLabel setText:name];
		[nameLabel setFont:[UIFont systemFontOfSize:12.0]];
		[nameLabel setBackgroundColor:[UIColor clearColor]];
		[nameLabel setTextColor:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]];
		[self addSubview:nameLabel];
		
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



- (void)buttonTapped:(id)sender {
	
	UIButton *btn = (UIButton *)sender;
	
	if (![btn isSelected]){
		
		[btn setSelected:YES];
		[btn setHighlighted:NO];
	}
	
	else [btn setSelected:NO];
	
	[self.delegate userButtonTapped:self.username];
}


- (void)initImageDownload:(NSString *)urlString {
		
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
		
		[self.thumbView setImage:requestedImage];
	}];
	[operation start];
}


@end
