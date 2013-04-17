//
//  TAThumbsSlider.m
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import "TAThumbsSlider.h"
#import "ThumbImage.h"

#define SCROLL_VIEW_HEIGHT 81.0
#define GUIDE_SCROLL_VIEW_HEIGHT 70.0
#define SCROLL_VIEW_X_POS 7.0

@implementation TAThumbsSlider

@synthesize delegate, scrollView, sliderMode;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title photosCount:(NSString *)photosCount {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        
        UIColor *headingColor = [UIColor colorWithRed:75.0/255.0 green:25.0/255.0 blue:0.0/255.0 alpha:1.0];
		
		// Heading label
		CGFloat labelHeight = 45.0;
		CGRect headingFrame = CGRectMake(10.0, 0.0, frame.size.width, labelHeight);
		UILabel *headingLabel = [[UILabel alloc] initWithFrame:headingFrame];
		[headingLabel setBackgroundColor:[UIColor clearColor]];
		[headingLabel setText:title];
		[headingLabel setFont:[UIFont systemFontOfSize:26.0]];
        [headingLabel setTextColor:headingColor];
        [headingLabel setShadowColor:[UIColor colorWithRed:206.0/255.0 green:125.0/255.0 blue:86.0/255.0 alpha:1.0]];
        [headingLabel setShadowOffset:CGSizeMake(0, 1)];
		
		[self addSubview:headingLabel];
		
        
		// Create scroll view
		CGRect svFrame = CGRectMake(0.0, labelHeight, frame.size.width, SCROLL_VIEW_HEIGHT);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setShowsHorizontalScrollIndicator:NO];
		[sv setShowsVerticalScrollIndicator:NO];
		
		[sv setContentInset:UIEdgeInsetsMake(0.0, SCROLL_VIEW_X_POS, 0.0, SCROLL_VIEW_X_POS)];
		
		self.scrollView = sv;
		
		[self addSubview:self.scrollView];
        
        
        // Create progress view to show the download progress of this
        // particular request
        CGFloat progressYPos = self.scrollView.center.y - 5.0;
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [progressView setTrackImage:[UIImage imageNamed:@"progress-tile-bg.png"]];
        [progressView setProgressImage:[UIImage imageNamed:@"progress-tile.png"]];
        [progressView setFrame:CGRectMake(10.0, progressYPos, 150.0, 9.0)];
        
        self.progressBar = progressView;

        
        [self addSubview:self.progressBar];
		
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame title:(NSString *)title username:(NSString *)username lovesCount:(NSString *)lovesCount photosCount:(NSString *)photosCount {
	
    self = [super initWithFrame:frame];
	
    if (self) {
        
        CGFloat viewLeftPadding = 14.0;
        
		// Create scroll view
		CGRect svFrame = CGRectMake(0.0, 0.0, frame.size.width, GUIDE_SCROLL_VIEW_HEIGHT);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setShowsHorizontalScrollIndicator:NO];
		[sv setShowsVerticalScrollIndicator:NO];
		
		[sv setContentInset:UIEdgeInsetsMake(0.0, SCROLL_VIEW_X_POS, 0.0, SCROLL_VIEW_X_POS)];
		
		self.scrollView = sv;
		
		[self addSubview:self.scrollView];
        
        
        
        // Create progress view to show the download progress of this
        // particular request
        CGFloat progressYPos = self.scrollView.center.y - 5.0;
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        [progressView setTrackImage:[UIImage imageNamed:@"progress-tile-bg.png"]];
        [progressView setProgressImage:[UIImage imageNamed:@"progress-tile.png"]];
        [progressView setFrame:CGRectMake(10.0, progressYPos, 150.0, 9.0)];
        
        self.progressBar = progressView;

        
        [self addSubview:self.progressBar];        
        
        
        CGFloat labelTopPadding = 0.0;
        CGFloat labelYPos = GUIDE_SCROLL_VIEW_HEIGHT + labelTopPadding;
        UIColor *headingColor = [UIColor whiteColor];
		
		// Heading label
		CGFloat labelHeight = 30.0;
		CGRect headingFrame = CGRectMake(viewLeftPadding, labelYPos, frame.size.width, labelHeight);
		UILabel *headingLabel = [[UILabel alloc] initWithFrame:headingFrame];
		[headingLabel setBackgroundColor:[UIColor clearColor]];
		[headingLabel setText:title];
		[headingLabel setFont:[UIFont systemFontOfSize:26.0]];
        [headingLabel setTextColor:headingColor];
        [headingLabel setShadowColor:[UIColor colorWithRed:153.0/255.0 green:62.0/255.0 blue:19.0/255.0 alpha:1.0]];
        [headingLabel setShadowOffset:CGSizeMake(0, 1)];
		
		[self addSubview:headingLabel];
        
        
        UIColor *detailsColor = [UIColor blackColor];
        UIFont *detailsFont = [UIFont systemFontOfSize:10.0];
        CGFloat detailsBtnHeight = 18.0;
        CGFloat detailsBtnYPos = labelYPos + labelHeight;
        
        // USERNAME BUTTON
        CGFloat usernameBtnWidth = 90.0;
        
		UIButton *usernameBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[usernameBtn setFrame:CGRectMake(viewLeftPadding, detailsBtnYPos, usernameBtnWidth, detailsBtnHeight)];
        [usernameBtn setBackgroundColor:[UIColor clearColor]];
        [usernameBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [usernameBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [usernameBtn setTitle:[username uppercaseString] forState:UIControlStateNormal];
        [usernameBtn setTitleColor:detailsColor forState:UIControlStateNormal];
        [usernameBtn.titleLabel setFont:detailsFont];
        [usernameBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [usernameBtn setEnabled:NO];
        [usernameBtn setAdjustsImageWhenDisabled:NO];
        [usernameBtn setImage:[UIImage imageNamed:@"guide-username-button.png"] forState:UIControlStateNormal];
                
        [self addSubview:usernameBtn];
        
        
        // PHOTOS BUTTON
        CGFloat photosBtnWidth = 90.0;
        CGFloat photosXPos = viewLeftPadding + usernameBtnWidth;
        
		UIButton *photosBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[photosBtn setFrame:CGRectMake(photosXPos, detailsBtnYPos, photosBtnWidth, detailsBtnHeight)];
        [photosBtn setBackgroundColor:[UIColor clearColor]];
        [photosBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [photosBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [photosBtn setTitle:[NSString stringWithFormat:@"%@ PHOTOS", photosCount] forState:UIControlStateNormal];
        [photosBtn setTitleColor:detailsColor forState:UIControlStateNormal];
        [photosBtn.titleLabel setFont:detailsFont];
        [photosBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [photosBtn setEnabled:NO];
        [photosBtn setAdjustsImageWhenDisabled:NO];
        
        [photosBtn setImage:[UIImage imageNamed:@"guide-photos-button.png"] forState:UIControlStateNormal];
        
        [self addSubview:photosBtn];
        
        
        // LOVES BUTTON
        CGFloat lovesBtnWidth = 90.0;
        CGFloat lovesXPos = photosXPos + photosBtnWidth;
        
		UIButton *lovesBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[lovesBtn setFrame:CGRectMake(lovesXPos, detailsBtnYPos, lovesBtnWidth, detailsBtnHeight)];
        [lovesBtn setBackgroundColor:[UIColor clearColor]];
        [lovesBtn addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
        [lovesBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [lovesBtn setTitle:[NSString stringWithFormat:@"%@ LOVES", lovesCount] forState:UIControlStateNormal];
        [lovesBtn setTitleColor:detailsColor forState:UIControlStateNormal];
        [lovesBtn.titleLabel setFont:detailsFont];
        [lovesBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [lovesBtn setEnabled:NO];
        [lovesBtn setAdjustsImageWhenDisabled:NO];
        
        [lovesBtn setImage:[UIImage imageNamed:@"guide-loves-button.png"] forState:UIControlStateNormal];
        
        [self addSubview:lovesBtn];
		
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


- (void)setImages:(NSMutableArray *)imagesArray {

	images = [imagesArray copy];
	
	[self populateScrollView:images];
}


- (void)populateScrollView:(NSArray *)imagesArray {
	
    CGFloat thumbWidth = 67.0;
	CGFloat thumbHeight = 67.0;
    
	CGFloat xPos = 0.0;
	CGFloat yPos = (self.scrollView.frame.size.height/2) - (thumbHeight/2);
	CGFloat padding = 1.0;
    
    
    // Clear out any 'old'/existing thumbnails
    // that are still in the scroll view
    if ([self.scrollView.subviews count] > 0)
        [self clearThumbnails];
    
	
	for (NSDictionary *imageData in imagesArray) {
		
		NSString *thumbID = [[imageData allKeys] lastObject];
		NSString *url = [imageData objectForKey:thumbID];
		
		CGRect thumbFrame = CGRectMake(xPos, yPos, thumbWidth, thumbHeight);
		ThumbImage *thumb = [[ThumbImage alloc] initWithFrame:thumbFrame url:url thumbID:thumbID];
		[thumb setDelegate:self];
		
		[self.scrollView addSubview:thumb];

		
		xPos += (thumbWidth + padding);
	}
	
	// Accomodate all the images to be scrolled to
	// by adjusting the scroll view's content size
	CGFloat contentWidth = ([imagesArray count] * (thumbWidth + padding));
	[self.scrollView setContentSize:CGSizeMake(contentWidth, self.scrollView.frame.size.height)];
}


// This removes all the ThumbImages
// that are currently in the scrollView
- (void)clearThumbnails {

    for (ThumbImage *thumb in self.scrollView.subviews)
        [thumb removeFromSuperview];
}


#pragma ThumbImageDelegate methods 

/* 
	A thumb image within the scroll view
	has been tapped. We want to pass the ID
	associated with said thumb back to 
	the delegate so it can act. */
- (void)thumbTapped:(NSString *)thumbID {

	[self.delegate thumbTappedWithID:thumbID fromSlider:self];
}



@end
