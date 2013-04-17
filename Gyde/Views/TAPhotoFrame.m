//
//  TAPhotoFrame.m
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAPhotoFrame.h"
#import "UIImageView+AFNetworking.h"
#import "ImageManager.h"
#import "TACommentView.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "TAGuideButton.h"
#import "TACreateGuideForm.h"
#import "TAMapView.h"
#import "TAUserButton.h"
#import "TARecommendList.h"

#define MAIN_WIDTH 301
#define MAIN_HEIGHT 301
#define CONTAINER_START_POINT -349.0
#define SCROLL_COLUMN_WIDTH 272.0
#define SCROLL_COLUMN_PADDING 10
#define SCROLL_COLUMN_INNER_PADDING 14

#define ANIMATION_DURATION_SLOW 0.5
#define ANIMATION_DURATION_FAST 0.25

#define INNER_VIEW_TAG 8888

@implementation TAPhotoFrame

@synthesize imageView, progressView, urlString, delegate, avatarView, container;
@synthesize containerView, actionsScrollView, actionsView, containerScroll;
@synthesize imageID, guides, selectedCity, selectedTagID, guidesView, createGuideView;
@synthesize latitude, longitude, followers, recommendListView, selectedTag;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)_imageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL tag:(NSString *)tagTitle vouches:(NSInteger)vouches loves:(NSInteger)loves timeElapsed:(NSString *)timeElapsed {

	self = [super initWithFrame:frame];
	
    if (self) {
		
		self.imageID = _imageID;
		self.selectedTag = tagTitle;
		
		
		/* 
			STRUCTURE
		 
			First layer is a UIView that acts as
			the container of all the content within in this 'Photo frame'.
			Second layer is another UIView, followed by a scroll view
			(ActionsScrollView) which will contain all the content
			related to actions.
		 */
		
		CGRect cvFrame = CGRectMake(9.0, CONTAINER_START_POINT, MAIN_WIDTH, 708.0);
		UIView *cv = [[UIView alloc] initWithFrame:cvFrame];
		[cv setBackgroundColor:[UIColor clearColor]];
		self.containerView = cv;
		
		[self addSubview:self.containerView];
		
		CGRect cFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 708.0);
		UIView *c = [[UIView alloc] initWithFrame:cFrame];
		[c setBackgroundColor:[UIColor clearColor]];
		self.container = c;
		
		[self.containerView addSubview:self.container];	
		
		
		// SCROLL VIEW
		CGRect svFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 349.0);
		UIScrollView *sv = [[UIScrollView alloc] initWithFrame:svFrame];
		[sv setBackgroundColor:[UIColor clearColor]];
		[sv setPagingEnabled:YES];
		self.actionsScrollView = sv;
		
		[self.container addSubview:self.actionsScrollView];
		

		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(SCROLL_COLUMN_INNER_PADDING, 10.0, SCROLL_COLUMN_WIDTH, 330.0);
		UIScrollView *av = [[UIScrollView alloc] initWithFrame:avFrame];
        
		self.actionsView = av;
		
		[self.actionsScrollView addSubview:self.actionsView];
		
        
        // ACTIONS AREA BG
        CGRect bgFrame = CGRectMake(0.0, 0.0, SCROLL_COLUMN_WIDTH, 243.0);
		UIImageView *bgImage = [[UIImageView alloc] initWithFrame:bgFrame];
		[bgImage setImage:[UIImage imageNamed:@"photo-actions-shadow-bg.png"]];
		[self.actionsView addSubview:bgImage];        
        
		
		[self populateActionsView];
		
		
		/*	
			SHADOW OVERLAY FOR 
			THE ACTIONS SCROLL VIEW
		*/
		CGRect overlayFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 351.0);
		UIImageView *overlayImage = [[UIImageView alloc] initWithFrame:overlayFrame];
		[overlayImage setImage:[UIImage imageNamed:@"photo-actions-shadow-overlay.png"]];
		[self.container addSubview:overlayImage];
		
		
		
		/*	
			IMAGE DISPLAY 
		 
			UIImageView for the polaroid image artwork, with 
			a TAPhotoView on top of that as our placeholder
			for the actual image that is being downloaded
			to be placed into.
		*/
		
		CGRect polaroidFrame = CGRectMake(0.0, 359.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
		[self.container addSubview:polaroidBG];
		
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(10.0, 369.0, 281.0, 281.0);
		TAPhotoView *iView = [[TAPhotoView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor lightGrayColor]];
		self.imageView = iView;
		
		[self.container addSubview:self.imageView];
		
		
		/*
			PROGRESS INDICATOR
		 
			Progress Indicator is a property as it needs
			to be updated regularly as the main image download
			is progressing.
		*/
		CGRect mainViewFrame = self.imageView.frame;
		CGFloat progressXPos = (mainViewFrame.size.width/2.0) - 75.0;
		CGFloat progressYPos = mainViewFrame.origin.y + ((mainViewFrame.size.height/2.0) - 4.0);
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self.container addSubview:self.progressView];
		
		
		
		// PULL BUTTON
		CGRect btnFrame = CGRectMake(((cFrame.size.width/2)-39.0), 346.0, 78.0, 58.0);
		TAPullButton *pullBtn = [[TAPullButton alloc] initWithFrame:btnFrame];
		[pullBtn setFrame:btnFrame];
		[pullBtn setDelegate:self];
		
		[self.container addSubview:pullBtn];
		
		
		// IMAGE URL
		self.urlString = imageURLString;
		
        
        CGFloat fontSize = 13.0;
		
		// CAPTION
		CGFloat labelYPos = iViewFrame.origin.y + iViewFrame.size.height + 10.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, labelYPos, MAIN_WIDTH, 18.0)];
		[captionLabel setText:caption];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
		[self.container addSubview:captionLabel];
		
		
		// USERNAME BUTTON
        CGFloat btnXPos = 28.0;
		CGFloat usernameYPos = iViewFrame.origin.y + iViewFrame.size.height + 10.0 + 24.0;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(btnXPos, usernameYPos, 195.0, 14.0)];
		[btn setTitle:username forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameClicked:) forControlEvents:UIControlEventTouchUpInside];		
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn sizeToFit];
        
        CGFloat usernameWidth = btn.frame.size.width;
        
		[self.container addSubview:btn];
        
        
        // TIME ELAPSED BUTTON
        CGFloat leftPadding = 10.0;
        btnXPos += (usernameWidth + leftPadding);
        UIFont *btnFont = [UIFont systemFontOfSize:fontSize];
        CGSize expectedLabelSize = [timeElapsed sizeWithFont:btnFont];
        
		UIButton *timeElapsedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[timeElapsedBtn setFrame:CGRectMake(btnXPos, usernameYPos, (13 + expectedLabelSize.width), 15.0)];
        [timeElapsedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [timeElapsedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [timeElapsedBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [timeElapsedBtn.titleLabel setFont:btnFont];
        [timeElapsedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [timeElapsedBtn setBackgroundColor:[UIColor clearColor]];
        [timeElapsedBtn setImage:[UIImage imageNamed:@"photo-time-icon.png"] forState:UIControlStateNormal];
        
        [timeElapsedBtn setTitle:timeElapsed forState:UIControlStateNormal];

        [timeElapsedBtn setEnabled:NO];
        [timeElapsedBtn setAdjustsImageWhenDisabled:NO];
        
        CGFloat timeElapsedWidth = timeElapsedBtn.frame.size.width;
        
		[self.container addSubview:timeElapsedBtn];
		
        
        // LOVES BUTTON
        btnXPos += (timeElapsedWidth + leftPadding);
        leftPadding = 10.0;
        CGSize expectedLovesSize = [[NSString stringWithFormat:@"%i", loves] sizeWithFont:btnFont];
        
		UIButton *lovesCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[lovesCountBtn setFrame:CGRectMake(btnXPos, usernameYPos, (14+expectedLovesSize.width), 15.0)];
        [lovesCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [lovesCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [lovesCountBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [lovesCountBtn setBackgroundColor:[UIColor clearColor]];
		[lovesCountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lovesCountBtn.titleLabel setFont:btnFont];
        [lovesCountBtn setImage:[UIImage imageNamed:@"photo-loves-icon.png"] forState:UIControlStateNormal];
        
        [lovesCountBtn setTitle:[NSString stringWithFormat:@"%i", loves] forState:UIControlStateNormal];
        
        [lovesCountBtn setEnabled:NO];
        [lovesCountBtn setAdjustsImageWhenDisabled:NO];
        
        
        CGFloat lovesCountWidth = lovesCountBtn.frame.size.width;
        
		[self.container addSubview:lovesCountBtn];
        
        
        
        // VOUCHES BUTTON
        btnXPos += (lovesCountWidth + leftPadding);
        leftPadding = 10.0;
        CGSize expectedVouchesSize = [[NSString stringWithFormat:@"%i", vouches] sizeWithFont:btnFont];
        
		UIButton *vouchesCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[vouchesCountBtn setFrame:CGRectMake(btnXPos, usernameYPos, (13+expectedVouchesSize.width), 15.0)];
        [vouchesCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [vouchesCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [vouchesCountBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
		[vouchesCountBtn setTitle:[NSString stringWithFormat:@"%i", vouches] forState:UIControlStateNormal];
        [vouchesCountBtn setBackgroundColor:[UIColor clearColor]];
		[vouchesCountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [vouchesCountBtn setImage:[UIImage imageNamed:@"photo-vouches-icon.png"] forState:UIControlStateNormal];
        
		[vouchesCountBtn.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
        [vouchesCountBtn setEnabled:NO];
        [vouchesCountBtn setAdjustsImageWhenDisabled:NO];
        
        
		[self.container addSubview:vouchesCountBtn];
        
		
		// Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, usernameYPos, 15.0, 15.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self.container addSubview:self.avatarView];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
	}
	
	return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


#pragma PullButtonDelegate methods 

- (void)buttonTouched {

	[self.delegate disableScroll];
	//NSLog(@"GOTCHA'");
}


- (void)buttonPulledDown:(CGFloat)shift {

	//NSLog(@"SHIFT:%f", shift);
	
	CGRect newFrame = self.containerView.frame;
	newFrame.origin.y = (newFrame.origin.y - shift);
	
	[self.containerView setFrame:newFrame];
}


- (void)buttonPulledToPoint:(CGFloat)yPos {

	CGRect newFrame = self.containerView.frame;
	newFrame.origin.y +=  (CONTAINER_START_POINT + yPos);
	
	[self.containerView setFrame:newFrame];
}


- (void)pullDownEnded:(CGFloat)lastYPos pullingUpward:(BOOL)pullingUpward {
	
	CGFloat yPos = (CONTAINER_START_POINT + lastYPos);
	CGRect newFrame = self.containerView.frame;
	CGFloat duration = ANIMATION_DURATION_FAST;
	
	BOOL showCloseBtn = NO;
	
	if (pullingUpward) { 
	
		if (yPos >= -14.0) {
			
			newFrame.origin.y = CONTAINER_START_POINT;
			duration = ANIMATION_DURATION_SLOW;
            viewingActionsList = NO;
		}
		
		else {
			
			newFrame.origin.y = 0.0;
			showCloseBtn = YES;
            viewingActionsList = YES;
		}
	}
	
	else {
		
		if (yPos >= 0.0) {
			
			newFrame.origin.y = 0.0;
			showCloseBtn = YES;
            viewingActionsList = YES;
		}
		
		else {
			
			newFrame.origin.y = CONTAINER_START_POINT;
			duration = ANIMATION_DURATION_SLOW;
            viewingActionsList = NO;
		}
	}
	
	// Conduct animation of containerView frame
	[UIView animateWithDuration:duration animations:^{
		
		self.containerView.frame = newFrame;
		
	} completion:^(BOOL finished) {
		
		[self.delegate enableScroll];
		
		[self.delegate showCloseButton:showCloseBtn];
	}];
}



#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

	if (pullEnabled) {
	
		NSLog(@"Y OFFSET:%f", scrollView.contentOffset.y);
	}	
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

	if (pullEnabled) {
	
		
	}
}


- (void)populateActionsView {
	
	CGFloat xPos = 1.0;
	CGFloat yPos = 0.0;
	CGFloat buttonWidth = 270.0;
	CGFloat buttonHeight = 40.0;
	//CGFloat buttonPadding = 1.0;

	// ADD TO GUIDE BUTTON
	CGRect addToGuideFrame = CGRectMake(xPos, yPos, buttonWidth, 41);
	
	UIButton *addToGuideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[addToGuideBtn setFrame:addToGuideFrame];
	[addToGuideBtn setImage:[UIImage imageNamed:@"add-to-guide-button.png"] forState:UIControlStateNormal];
	[addToGuideBtn addTarget:self action:@selector(addToGuideButtonTapped:) forControlEvents:UIControlEventTouchUpInside];	
	[self.actionsView addSubview:addToGuideBtn];
	
	
	yPos += 41;
	
	
	// VIEW ON MAP BUTTON
	CGRect mapFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *viewOnMapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[viewOnMapBtn setFrame:mapFrame];
	[viewOnMapBtn setImage:[UIImage imageNamed:@"view-on-map-button.png"] forState:UIControlStateNormal];
	[viewOnMapBtn addTarget:self action:@selector(viewOnMapButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[self.actionsView addSubview:viewOnMapBtn];
	
	
	yPos += buttonHeight;
	
	
	// LOVE BUTTON
	CGRect loveFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[loveBtn setFrame:loveFrame];
	[loveBtn setImage:[UIImage imageNamed:@"love-photo-button.png"] forState:UIControlStateNormal];
	[loveBtn addTarget:self action:@selector(loveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];			
	[self.actionsView addSubview:loveBtn];
	
	
	yPos += buttonHeight;
	
	
	// COMMENT BUTTON
	CGRect commentFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[commentBtn setFrame:commentFrame];
	[commentBtn setImage:[UIImage imageNamed:@"add-comment-button.png"] forState:UIControlStateNormal];
	[commentBtn addTarget:self action:@selector(commentButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[self.actionsView addSubview:commentBtn];
	
	
	yPos += buttonHeight;
	
	
	// VOUCH BUTTON
	CGRect vouchFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *vouchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[vouchBtn setFrame:vouchFrame];
	[vouchBtn setImage:[UIImage imageNamed:@"vouch-button.png"] forState:UIControlStateNormal];
	[vouchBtn addTarget:self action:@selector(vouchButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[self.actionsView addSubview:vouchBtn];
	
	
	yPos += buttonHeight;
	
	
	// FLAG BUTTON
	CGRect flagFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);
	
	UIButton *flagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[flagBtn setFrame:flagFrame];
	[flagBtn setImage:[UIImage imageNamed:@"flag-photo-button.png"] forState:UIControlStateNormal];
	[flagBtn addTarget:self action:@selector(flagButtonTapped:) forControlEvents:UIControlEventTouchUpInside];				
	[self.actionsView addSubview:flagBtn];
	
	
	yPos += (buttonHeight + 5.0);
	
	
	// TWEET BUTTON
	CGRect tweetFrame = CGRectMake(xPos, yPos, 42.0, 42.0);
	
	UIButton *tweetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[tweetBtn setFrame:tweetFrame];
    [tweetBtn setImage:[UIImage imageNamed:@"tweet-photo-button.png"] forState:UIControlStateNormal];
    [tweetBtn setImage:[UIImage imageNamed:@"tweet-photo-button-on.png"] forState:UIControlStateHighlighted];
	[tweetBtn addTarget:self action:@selector(tweetButtonTapped:) forControlEvents:UIControlEventTouchUpInside];			
	[self.actionsView addSubview:tweetBtn];
	
	
	// EMAIL BUTTON
	CGRect emailFrame = CGRectMake((xPos + 42.0 + 3.0), yPos, 42.0, 42.0);
	
	UIButton *emailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[emailBtn setFrame:emailFrame];
	[emailBtn setImage:[UIImage imageNamed:@"facebook-photo-button.png"] forState:UIControlStateNormal];
    [emailBtn setImage:[UIImage imageNamed:@"facebook-photo-button-on.png"] forState:UIControlStateHighlighted];
	[emailBtn addTarget:self action:@selector(emailButtonTapped:) forControlEvents:UIControlEventTouchUpInside];		
	[self.actionsView addSubview:emailBtn];
    
    
    // RECOMMEND BUTTON
	CGRect recommendFrame = CGRectMake((emailFrame.origin.x + emailFrame.size.width + 3.0) , yPos, 181.0, 42.0);
     
    UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recommendBtn setFrame:recommendFrame];
    [recommendBtn setImage:[UIImage imageNamed:@"recommend-photo-button.png"] forState:UIControlStateNormal];
    [recommendBtn setImage:[UIImage imageNamed:@"recommend-photo-button-on.png"] forState:UIControlStateHighlighted];
    [recommendBtn addTarget:self action:@selector(recommendButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.actionsView addSubview:recommendBtn];
}


#pragma CreateGuideFormDelegate methods 

- (void)createGuide:(NSString *)title privateGuide:(BOOL)privateGuide {

	[self returnToActions];
	
	[self.delegate createGuideWithPhoto:self.imageID title:title isPrivate:privateGuide];
}


#pragma GuideButtonDelegate methods 

- (void)selectedGuide:(NSString *)guideID {

	[self returnToActions];
	
	[self.delegate addPhotoToSelectedGuide:guideID];
}


#pragma CommentViewDelegate methods 

- (void)commentReadyForSubmit:(NSString *)commentText {
	
	[self returnToActions];

	[self.delegate commentButtonTapped:self.imageID commentText:commentText];
}


#pragma RecommendListDelegate methods

- (void)finishedSelectingUsers:(NSMutableArray *)selectedUsers {

	[self returnToActions];
	
	[self initRecommendAPI:selectedUsers];
}


#pragma MY METHODS 

- (void)initAvatarImage:(NSString *)avatarURLString {
	
	if (avatarURLString && !self.avatarView.image) {
		
		[self.avatarView setBackgroundColor:[UIColor grayColor]];
		
		// Start the image request/download
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:avatarURLString]] success:^(UIImage *requestedImage) {
            self.avatarView.image = requestedImage;
            [self setNeedsDisplay];
        }];
        [operation start];
    }
}


- (void)initImage {
	
	if (self.urlString && !self.imageView.image) {
		
		UIImage *image = [ImageManager loadImage:[NSURL URLWithString:self.urlString] progressIndicator:self.progressView];
		
		if (image) {
			
			// Hide progress indicator
			[self.progressView setHidden:YES];
			
			self.imageView.image = image;
		}
    }
}


- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url {
	
    if ([[NSURL URLWithString:self.urlString] isEqual:_url]) {
		
		// Hide progress indicator
		[self.progressView setHidden:YES];
		
		//[self.loadingSpinner stopAnimating];
        self.imageView.image = image;
    }
}


- (void)returnToActions {
	
	// Reset the contentSize to the minimum width
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width = self.actionsScrollView.frame.size.width;
	self.actionsScrollView.contentSize = newSize;
	
	// Disable the actions scroll view from 
	// being interacted with
	self.actionsScrollView.userInteractionEnabled = NO;
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(0.0, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
        
        viewingActionsList = YES;
		
		self.actionsScrollView.userInteractionEnabled = YES;
		
		UIView *innerView = [self.actionsScrollView viewWithTag:INNER_VIEW_TAG];
		[innerView removeFromSuperview];
		
		UIView *innerView2 = [self.actionsScrollView viewWithTag:(INNER_VIEW_TAG+1)];
		if (innerView2) [innerView removeFromSuperview];

	}];
}


#pragma ACTIONS #############################################

- (void)usernameClicked:(id)sender {
	
	// pass info on to delegate
	[self.delegate usernameButtonClicked];
}


- (void)viewOnMapButtonTapped:(id)sender {

	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect commentFrame = CGRectMake(MAIN_WIDTH, 0.0, MAIN_WIDTH, 350.0);
	TAMapView *mapView = [[TAMapView alloc] initWithFrame:commentFrame latitude:[self latitude] longitude:[self longitude]];
	[mapView setTag:INNER_VIEW_TAG];
	
	[self.actionsScrollView addSubview:mapView];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(MAIN_WIDTH, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
        
        viewingActionsList = NO;
		
		self.actionsScrollView.userInteractionEnabled = YES;
		
		[self.delegate showCloseButton:YES];
	}];
}


- (void)tweetButtonTapped:(id)sender {

	[self.delegate tweetButtonTapped:self.imageID];
}


- (void)emailButtonTapped:(id)sender {
	
	[self.delegate emailButtonTapped:self.imageID];
}


- (void)recommendButtonTapped:(id)sender {

	// Trigger the "Followers" API
	[self initFollowersAPI];
}


- (void)loveButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveButtonTapped:self.imageID];
}


- (void)vouchButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate vouchButtonTapped:self.imageID];
}


- (void)flagButtonTapped:(id)sender {

	// pass info on to delegate
	[self.delegate flagButtonTapped:self.imageID];
}


- (void)commentButtonTapped:(id)sender {
	
	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect commentFrame = CGRectMake(MAIN_WIDTH, 0.0, MAIN_WIDTH, 330.0);
	TACommentView *commentView = [[TACommentView alloc] initWithFrame:commentFrame];
	[commentView setDelegate:self];
	[commentView setTag:INNER_VIEW_TAG];
	
	[self.actionsScrollView addSubview:commentView];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(MAIN_WIDTH, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
        
        viewingActionsList = NO;
		
		self.actionsScrollView.userInteractionEnabled = YES;
		
		[self.delegate showCloseButton:YES];
	}];
}


- (void)addToGuideButtonTapped:(id)sender {
	
	// Find the existing Guides that this
	// photo can be added to be calling the
	// "MyGuides" API and then filtering
	// the results by the relevant city/tag
	[self initMyGuidesAPI];
}


#pragma ############### END OF ACTION BUTTON METHODS ###################################


- (void)initFindGuidesAPI {
	
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&tag=%i&city=%@&pg=%i&sz=%@&private=0&token=%@", [self appDelegate].loggedInUsername, [self.selectedTagID intValue], self.selectedCity, 0, @"4", [[self appDelegate] sessionToken]];
	
	NSLog(@"FIND GUIDES PARAMETERS:%@", jsonString);
	
	// Convert string to data for transmission
	NSData *jsonData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"FindGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Create URL request with URL and the JSON data
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:jsonData];
	
	// JSONFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self
													 action:@selector(receivedFindGuidesResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedFindGuidesResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING FIND GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		self.guides = [results objectForKey:@"guides"];
		
//		[jsonString release];
    }
	
	// Reload the table
	[self goToGuidesView];
    
//    [guidesFetcher release];
    guidesFetcher = nil;
}


- (void)initMyGuidesAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&token=%@", [self appDelegate].loggedInUsername, [[self appDelegate] sessionToken]];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"MyGuides";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// JSONFetcher
	guidesFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												   receiver:self action:@selector(receivedMyGuidesResponse:)];
	[guidesFetcher start];
}


// Example fetcher response handling
- (void)receivedMyGuidesResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == guidesFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	//NSLog(@"PRINTING MY GUIDES:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
	
	//loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		//guidesLoaded = YES;
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		NSArray *guidesArray = [results objectForKey:@"guides"];
		
		NSArray *tempGuides = [[self appDelegate] serializeGuideData:guidesArray];
		
		self.guides = (NSMutableArray *)[tempGuides filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"city.title = %@ AND tag.tagID = %@", self.selectedCity, self.selectedTagID]];
		
//		[jsonString release];
	}
	
	// Reload the table
	[self goToGuidesView];
	
//	[guidesFetcher release];
	guidesFetcher = nil;
}


- (void)closeButtonWasTapped {

    // If the user is viewing the
    // main actions list then we
    // want to animate the pull down
    // button (ribbon) up to the top
    if (viewingActionsList) {
    
        CGRect newFrame = self.containerView.frame;
        CGFloat duration = ANIMATION_DURATION_FAST;
        newFrame.origin.y = CONTAINER_START_POINT;
        
        // Conduct animation of containerView frame
        [UIView animateWithDuration:duration animations:^{
            
            self.containerView.frame = newFrame;
            
        } completion:^(BOOL finished) {
            
            [self.delegate enableScroll];
            
            [self.delegate showCloseButton:NO];
        }];
    }
    
    else {
        
        // Animate the user back to the
        // main list of photo functions
        [self returnToActions];
    }
}


- (void)goToRecommendUsersList {

	// Disable the actions scroll view from
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect guidesFrame = CGRectMake(SCROLL_COLUMN_WIDTH, 0.0, 290.0, 330.0);
	
	TARecommendList *rlv = [[TARecommendList alloc] initWithFrame:guidesFrame];
	[rlv setUsers:self.followers];
	[rlv setTag:INNER_VIEW_TAG];
	[rlv setDelegate:self];
	
	self.recommendListView = rlv;
	
	[self.actionsScrollView addSubview:self.recommendListView];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(SCROLL_COLUMN_WIDTH, 0.0);
	
	[UIView animateWithDuration:ANIMATION_DURATION_SLOW animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;
		
	} completion:^(BOOL finished) {
		
        viewingActionsList = NO;
        
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)goToGuidesView {

	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	if (!self.guidesView) {
		
		CGRect guidesFrame = CGRectMake(MAIN_WIDTH, 0.0, MAIN_WIDTH, 330.0);
		
		UIView *gv = [[UIView alloc] initWithFrame:guidesFrame];
		[gv setTag:INNER_VIEW_TAG];
		
		self.guidesView = gv;
		
		[self.actionsScrollView addSubview:self.guidesView];
		
		[self createGuideButtons];
	}
	
	else {
		
		[self clearGuideButtons];
		
		[self.actionsScrollView addSubview:self.guidesView];
		
		[self createGuideButtons];
	}
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(MAIN_WIDTH, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
        
        viewingActionsList = NO;
		
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)createGuideButtons {
	
	CGFloat xPos = SCROLL_COLUMN_PADDING;
	CGFloat yPos = 10.0;
	CGFloat buttonWidth = SCROLL_COLUMN_WIDTH;
	CGFloat buttonHeight = 45.0;
	CGFloat buttonPadding = 3.0;
	
	for (Guide *guide in self.guides) {
		
		// ADD TO GUIDE BUTTON
		CGRect guideBtnFrame = CGRectMake(xPos, yPos, buttonWidth, buttonHeight);

		
		/*	NOTE!
			Guide object doesn't currently store a 
			"lovesCount" type of property. For now "0"
			is being set for all Guide buttons. */
		
		TAGuideButton *guideBtn = [[TAGuideButton alloc] initWithFrame:guideBtnFrame title:[guide title] loves:@"0" thumbURL:[guide thumbURL]];
		[guideBtn setGuideID:[guide guideID]];
		[guideBtn setDelegate:self];
		
		[self.guidesView addSubview:guideBtn];
		
		yPos += (buttonHeight + buttonPadding);
	}
	
	
	// 'CREATE A NEW GUIDE' BUTTON
	CGRect newFrame = CGRectMake(xPos, yPos, buttonWidth, 37.0);
	UIButton *addToNewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
	[addToNewBtn setFrame:newFrame];
	[addToNewBtn setImage:[UIImage imageNamed:@"create-new-guide-button.png"] forState:UIControlStateNormal];
	[addToNewBtn addTarget:self action:@selector(goToNewGuide:) forControlEvents:UIControlEventTouchUpInside];
	[addToNewBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];		
	[self.guidesView addSubview:addToNewBtn];
}


- (void)guideButtonTapped:(id)sender {

	NSLog(@"HEY");
}


- (void)goToNewGuide:(id)sender {
	
	// Disable the actions scroll view from 
	// being interacted with
	CGSize newSize = self.actionsScrollView.contentSize;
	newSize.width += MAIN_WIDTH;
	self.actionsScrollView.contentSize = newSize;
	self.actionsScrollView.userInteractionEnabled = NO;
	
	
	CGRect guidesFrame = CGRectMake((SCROLL_COLUMN_WIDTH*2), 0.0, MAIN_WIDTH, 330.0);
	
	TACreateGuideForm *gv = [[TACreateGuideForm alloc] initWithFrame:guidesFrame city:self.selectedCity tag:self.selectedTag];
	[gv setTag:(INNER_VIEW_TAG+1)];
	[gv setDelegate:self];
	
	self.createGuideView = gv;
	
	[self.actionsScrollView addSubview:self.createGuideView];
	
	// Animate across to the comment view
	CGPoint newOffset = CGPointMake(guidesFrame.origin.x, 0.0);
	
	[UIView animateWithDuration:0.25 animations:^{
		
		self.actionsScrollView.contentOffset = newOffset;        
		
	} completion:^(BOOL finished) {
		
		self.actionsScrollView.userInteractionEnabled = YES;
	}];
}


- (void)initNewGuideView {
	
	CGFloat xPos = 8.0;
	CGFloat yPos = 10.0;
	CGFloat bgWidth = 274.0;
	CGFloat bgHeight = 45.0;
	CGFloat padding = 1.0;

	// Add form field bgs
	UIImage *fieldBGImage = [UIImage imageNamed:@"form-field-bg-small.png"];
	
	
	for (int i = 0; i < 4; i++) {
	
		CGRect fieldFrame1 = CGRectMake(xPos, yPos, bgWidth, bgHeight);
		UIImageView *fieldViewBG = [[UIImageView alloc] initWithFrame:fieldFrame1];
		[fieldViewBG setImage:fieldBGImage];
		
		[self.createGuideView addSubview:fieldViewBG];
		
		yPos += (bgHeight + padding);
	}
}


- (void)initFollowersAPI {
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&pg=%i&sz=%i", [self appDelegate].loggedInUsername, 0, 12];
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Followers";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	followersFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												  receiver:self
													action:@selector(receivedFollowersResponse:)];
	[followersFetcher start];
}


// Example fetcher response handling
- (void)receivedFollowersResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
    
    NSAssert(aFetcher == followersFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// We are not loading
	//loading = NO;
	
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	//NSLog(@"PRINTING FOLLOWERS:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
    if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
        
        // Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		// Build an array from the dictionary for easy access to each entry
		NSMutableArray *newFollowers =  [[self appDelegate] serializeUsersData:[results objectForKey:@"users" ]];
		
		// Sort alphabetically by venue title
		NSSortDescriptor *alphaDesc = [[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		[newFollowers sortUsingDescriptors:[NSArray arrayWithObject:alphaDesc]];
		
		self.followers = newFollowers;
		
		// clean up
//		[jsonString release];
		
		// We've finished loading the artists
		//followersLoaded = YES;
    }
	
	// Reload the table
	[self goToRecommendUsersList];
    
//    [followersFetcher release];
    followersFetcher = nil;
}


- (void)initRecommendAPI:(NSMutableArray *)users {
	
	NSString *username = [self appDelegate].loggedInUsername;
	NSString *usernames = [users componentsJoinedByString:@","];
	
	NSString *postString = [NSString stringWithFormat:@"username=%@&code=%@&usernames=%@&token=%@", username, self.imageID, usernames, [self appDelegate].sessionToken];
	
	NSLog(@"PHOTO RECOMMEND DATA:%@", postString);
	
	NSData *postData = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"recommend";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	// HTTPFetcher
	recommendFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
													  receiver:self
														action:@selector(receivedRecommendResponse:)];
	[recommendFetcher start];
}


// Example fetcher response handling
- (void)receivedRecommendResponse:(HTTPFetcher *)aFetcher {
    
    HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	//NSLog(@"RECOMMEND RESPONSE:%@",[[NSString alloc] initWithData:theJSONFetcher.data encoding:NSASCIIStringEncoding]);
    
	NSAssert(aFetcher == recommendFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	// New image data;
	//NSDictionary *guideData;
	//BOOL submissionSuccess;
	
	if ([theJSONFetcher.data length] > 0) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) {
			
			//submissionSuccess = YES;
			
			//guideData = [results objectForKey:@"guide"];
		}
		
//		[jsonString release];
	}
	
	// Clean up
//	[recommendFetcher release];
	recommendFetcher = nil;
}


- (void)clearGuideButtons {

	for (UIView *button in self.guidesView.subviews) {
		
		[button removeFromSuperview];
	}
}



@end
