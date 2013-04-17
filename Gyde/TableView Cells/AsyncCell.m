//
//  AsyncCell.m
//  IOSBoilerplate
//
//  Copyright (c) 2011 Alberto Gimeno Brieba
//  
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//  
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//  

#import "AsyncCell.h"
#import "DictionaryHelper.h"

#import "UIImageView+AFNetworking.h"

@implementation AsyncCell

@synthesize info;
@synthesize image, delegate;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) 
    {
		self.backgroundColor = [UIColor whiteColor];
		self.opaque = YES;
    }
    return self;
}

- (void) prepareForReuse {
	[super prepareForReuse];
    self.image = nil;
}

static UIFont* system14 = nil;
static UIFont* system12 = nil;
static UIFont* bold14 = nil;

+ (void)initialize
{
	if(self == [AsyncCell class])
	{
		system14 = [[UIFont systemFontOfSize:14] retain];
		system12 = [[UIFont systemFontOfSize:12] retain];
		bold14 = [[UIFont boldSystemFontOfSize:12] retain];
	}
}


- (void) drawContentView:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	UIColor *bgColor;
	
	if (self.selected) bgColor = [UIColor cyanColor];
	else bgColor = [UIColor whiteColor];
	
	[bgColor set];
	CGContextFillRect(context, rect);
	
	CGFloat imageXPos = 5.0;
	CGFloat textXPos = 63.0;
	CGFloat dateWidth = 70;
	
	NSString *username = [info stringForKey:@"username"];
	NSString *name = [info stringForKey:@"name"];
	
	CGFloat widthr = (self.frame.size.width - textXPos) - dateWidth;
	
	[[UIColor blackColor] set];
	[username drawInRect:CGRectMake(textXPos, 5.0, widthr, 16.0) withFont:bold14 lineBreakMode:UILineBreakModeTailTruncation];
	
	[[UIColor grayColor] set];
	[name drawInRect:CGRectMake(textXPos, 21.0, widthr, 40.0) withFont:system14 lineBreakMode:UILineBreakModeTailTruncation];
	
	NSArray *keys = [self.info allKeys];
	
	if ([keys containsObject:@"following"]) {
		
		NSNumber *following = [self.info objectForKey:@"following"];
		
		if ([following intValue] == 1) {
			
			UIButton *followingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[followingBtn setFrame:CGRectMake(270.0, 10.0, 40.0, 30.0)];
			[followingBtn setTitle:@"Following" forState:UIControlStateNormal];
			[followingBtn addTarget:self action:@selector(followingButtonClicked:) forControlEvents:UIControlStateNormal];
			[self addSubview:followingBtn];
		}
		
		else {
			
			UIButton *followingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
			[followingBtn setFrame:CGRectMake(270.0, 10.0, 40.0, 30.0)];
			[followingBtn setTitle:@"Follow" forState:UIControlStateNormal];
			[followingBtn addTarget:self action:@selector(followingButtonClicked:) forControlEvents:UIControlStateNormal];
			[self addSubview:followingBtn];
		}
	}
	
	if (self.image) {
		
		CGRect r = CGRectMake(imageXPos, 5.0, 48.0, 48.0);
		[self.image drawInRect:r];
	}
}


- (void) updateCellInfo:(NSDictionary*)_info {
	self.info = _info;
    NSString *urlString = [info stringForKey:@"profile_image_url"];
	if (urlString) {
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
            self.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}


- (void) updateCellWithUsername:(NSString *)username withName:(NSString *)name 
					  imageURL:(NSString *)urlString {
	
	self.info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, username, urlString, nil] forKeys:[NSArray arrayWithObjects:@"name", @"username", @"imageURL", nil]];
	
	if (urlString) {
		
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
            self.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}


- (void) updateCellWithUsername:(NSString *)username withName:(NSString *)name 
					   imageURL:(NSString *)urlString followingUser:(BOOL)following {
	
	self.info = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:name, username, urlString, [NSNumber numberWithBool:following], nil] forKeys:[NSArray arrayWithObjects:@"name", @"username", @"imageURL", @"following", nil]];
	
	if (urlString) {
		
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
            self.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    if (selected)[self.backgroundView setBackgroundColor:[UIColor cyanColor]];
	else [self.backgroundView setBackgroundColor:[UIColor whiteColor]];
}


- (void)followingButtonClicked:(id)sender {
	
	[self.delegate followingButtonClicked:self];
}


@end
