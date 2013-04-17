//
//  TAPhotoDetails.m
//  Tourism App
//
//  Created by Richard Lee on 18/10/12.
//
//

#import "TAPhotoDetails.h"
#import "AppDelegate.h"
#import "UIImageView+AFNetworking.h"
#import "ImageManager.h"
#import "JSONKit.h"
#import "HTTPFetcher.h"
#import "Guide.h"
#import "User.h"
#import "Photo.h"
#import "Tag.h"

#define MAIN_WIDTH 301
#define MAIN_HEIGHT 301
#define CONTAINER_START_POINT 27.0
#define SCROLL_COLUMN_WIDTH 272.0
#define SCROLL_COLUMN_PADDING 10
#define SCROLL_COLUMN_INNER_PADDING 14

#define ANIMATION_DURATION_SLOW 0.5
#define ANIMATION_DURATION_FAST 0.25

#define INNER_VIEW_TAG 8888


@implementation TAPhotoDetails


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)selectedImageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL tag:(NSString *)tagTitle vouches:(NSInteger)vouches loves:(NSInteger)loves timeElapsed:(NSString *)timeElapsed {
    
	self = [super initWithFrame:frame];
	
    if (self) {
		
		self.imageID = selectedImageID;
		self.selectedTag = tagTitle;
        
        
        CGFloat topActionsBtnYPos = 10.0;
        CGFloat usernameXPos = 33.0;
        CGFloat fontSize = 13.0;
        CGFloat topRightActionsXPos = 160.0;
        CGFloat btnXPos = topRightActionsXPos;
        CGFloat leftPadding = 10.0;
        UIFont *btnFont = [UIFont systemFontOfSize:fontSize];
        
        
        // Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, topActionsBtnYPos, 15.0, 15.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self addSubview:self.avatarView];
		
		// Start downloading Avatar image
		[self initAvatarImage:avatarURL];
        
        
        // USERNAME BUTTON
		CGFloat usernameYPos = topActionsBtnYPos;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(usernameXPos, usernameYPos, 195.0, 15.0)];
		[btn setTitle:username forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameTapped:) forControlEvents:UIControlEventTouchUpInside];
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn sizeToFit];
        
		[self addSubview:btn];
        
        
        // TIME ELAPSED BUTTON
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
        
		[self addSubview:timeElapsedBtn];
		
        
        // LOVES BUTTON
        btnXPos += (timeElapsedWidth + leftPadding);
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
        
		[self addSubview:lovesCountBtn];
        
        
        // LOVE ACTION BUTTON
        btnXPos += (lovesCountWidth + leftPadding);
        CGFloat loveActionBtnWidth = 34.0;
        
		UIButton *loveActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[loveActionBtn setFrame:CGRectMake(btnXPos, usernameYPos, loveActionBtnWidth, 16.0)];
        
        [loveActionBtn setBackgroundColor:[UIColor redColor]];
		[loveActionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [loveActionBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        [loveActionBtn setTitle:@"LOVE" forState:UIControlStateNormal];
        [loveActionBtn addTarget:self action:@selector(loveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat loveActionWidth = loveActionBtn.frame.size.width;
        
		[self addSubview:loveActionBtn];
        
        
        // FLIP BUTTON
        btnXPos += (loveActionWidth + 5.0);
		CGFloat flipYPos = topActionsBtnYPos;
		UIButton *flipBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[flipBtn setFrame:CGRectMake(btnXPos, flipYPos, 25.0, 15.0)];
		[flipBtn setTitle:@"FLIP" forState:UIControlStateNormal];
        [flipBtn setBackgroundColor:[UIColor yellowColor]];
		[flipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[flipBtn addTarget:self action:@selector(flipPhoto) forControlEvents:UIControlEventTouchUpInside];
		[flipBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
		[self addSubview:flipBtn];
        
        
		
		/*
         STRUCTURE
		 
         First layer is a UIView that acts as
         the container of all the photo area.
         With this (containerView) are two main views -
         photoView and actionsView. The latter refers
         to a view that contains everything for the 'back' 
         of the photo.
        */
		
		CGRect cvFrame = CGRectMake(9.0, CONTAINER_START_POINT, MAIN_WIDTH, 302.0);
		UIView *cv = [[UIView alloc] initWithFrame:cvFrame];
		[cv setBackgroundColor:[UIColor clearColor]];
		self.containerView = cv;
		
		[self addSubview:self.containerView];

        
		CGRect cFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 708.0);
		UIView *c = [[UIView alloc] initWithFrame:cFrame];
		[c setBackgroundColor:[UIColor clearColor]];
		self.photoView = c;
		
		[self.containerView addSubview:self.photoView];
        
        
         /*
         IMAGE DISPLAY
		 
         UIImageView for the polaroid image artwork, with
         a TAPhotoView on top of that as our placeholder
         for the actual image that is being downloaded
         to be placed into.
         */
		
		CGRect polaroidFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
		[self.photoView addSubview:polaroidBG];
		
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(10.0, 0.0, 281.0, 281.0);
		TAPhotoView *iView = [[TAPhotoView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor clearColor]];
		self.imageView = iView;
		
		[self.photoView addSubview:self.imageView];
		
        
		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIView *av = [[UIView alloc] initWithFrame:avFrame];
        [av setBackgroundColor:[UIColor clearColor]];
        
		self.actionsView = av;
        
		UIImageView *actionsPolaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
        [self.actionsView addSubview:actionsPolaroidBG];
        
        //[self populateActionsView:photo];
        
        
		
		/*
         PROGRESS INDICATOR
		 
         Progress Indicator is a property as it needs
         to be updated regularly as the main image download
         is progressing.
         */
		CGRect imageViewFrame = self.imageView.frame;
		CGFloat progressXPos = imageViewFrame.origin.x + ((imageViewFrame.size.width/2.0) - 75.0);
		CGFloat progressYPos = imageViewFrame.origin.y + ((imageViewFrame.size.height/2.0) - 4.0);
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
        
		self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[self.progressView setFrame:progressFrame];
		[self.photoView addSubview:self.progressView];
		
		
		// IMAGE URL
		self.urlString = imageURLString;
		
		
        
		// CAPTION
		CGFloat labelYPos = 330.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, labelYPos, MAIN_WIDTH, 18.0)];
		[captionLabel setText:caption];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
		[self addSubview:captionLabel];
	}
	
	return self;
}


- (id)initWithFrame:(CGRect)frame forPhoto:(Photo *)photo loved:(BOOL)loved {
    
	self = [super initWithFrame:frame];
	
    if (self) {
		
		self.imageID = [photo photoID];
		self.selectedTag = [photo.tag title];
        self.isLoved = loved;
        self.selectedTagID = [photo.tag tagID];
        self.selectedCity = [photo.city title];
        
        CGFloat topActionsBtnYPos = 10.0;
        CGFloat usernameXPos = 33.0;
        CGFloat fontSize = 13.0;
        CGFloat topRightActionsXPos = 160.0;
        CGFloat btnXPos = topRightActionsXPos;
        CGFloat leftPadding = 10.0;
        UIFont *btnFont = [UIFont systemFontOfSize:fontSize];
        
        
        // Avatar image view
		UIImageView *aView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, topActionsBtnYPos, 15.0, 15.0)];
		[aView setBackgroundColor:[UIColor lightGrayColor]];
		self.avatarView = aView;
		[self addSubview:self.avatarView];
		
		// Start downloading Avatar image
		[self initAvatarImage:[photo.whoTook avatarURL]];
        
        
        // USERNAME BUTTON
		CGFloat usernameYPos = topActionsBtnYPos;
		UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn setFrame:CGRectMake(usernameXPos, usernameYPos, 195.0, 15.0)];
		[btn setTitle:[photo.whoTook username] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor clearColor]];
		[btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[btn addTarget:self action:@selector(usernameTapped:) forControlEvents:UIControlEventTouchUpInside];
		[btn.titleLabel setFont:[UIFont boldSystemFontOfSize:fontSize]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn sizeToFit];
        
		[self addSubview:btn];
        
        
        // TIME ELAPSED BUTTON
        CGSize expectedLabelSize = [[photo timeElapsed] sizeWithFont:btnFont];
        
		UIButton *timeElapsedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[timeElapsedBtn setFrame:CGRectMake(btnXPos, usernameYPos, (13 + expectedLabelSize.width), 15.0)];
        [timeElapsedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [timeElapsedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [timeElapsedBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [timeElapsedBtn.titleLabel setFont:btnFont];
        [timeElapsedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [timeElapsedBtn setBackgroundColor:[UIColor clearColor]];
        [timeElapsedBtn setImage:[UIImage imageNamed:@"photo-time-icon.png"] forState:UIControlStateNormal];
        
        [timeElapsedBtn setTitle:[photo timeElapsed] forState:UIControlStateNormal];
        
        [timeElapsedBtn setEnabled:NO];
        [timeElapsedBtn setAdjustsImageWhenDisabled:NO];
        
        CGFloat timeElapsedWidth = timeElapsedBtn.frame.size.width;
        
		[self addSubview:timeElapsedBtn];
		
        
        // LOVES BUTTON
        btnXPos += (timeElapsedWidth + leftPadding);
        CGSize expectedLovesSize = [[NSString stringWithFormat:@"%i", [photo.lovesCount intValue]] sizeWithFont:btnFont];
        
		UIButton *lovesCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[lovesCountBtn setFrame:CGRectMake(btnXPos, usernameYPos, (14+expectedLovesSize.width), 15.0)];
        [lovesCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [lovesCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [lovesCountBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [lovesCountBtn setBackgroundColor:[UIColor clearColor]];
		[lovesCountBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [lovesCountBtn.titleLabel setFont:btnFont];
        [lovesCountBtn setImage:[UIImage imageNamed:@"photo-loves-icon.png"] forState:UIControlStateNormal];
        
        [lovesCountBtn setTitle:[NSString stringWithFormat:@"%i", [photo.lovesCount intValue]] forState:UIControlStateNormal];
        
        [lovesCountBtn setEnabled:NO];
        [lovesCountBtn setAdjustsImageWhenDisabled:NO];
        
        CGFloat lovesCountWidth = lovesCountBtn.frame.size.width;
        
		[self addSubview:lovesCountBtn];
        
        
        // LOVE ACTION BUTTON
        btnXPos += (lovesCountWidth + leftPadding);
        CGFloat loveActionBtnWidth = 34.0;
        
		UIButton *loveActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[loveActionBtn setFrame:CGRectMake(btnXPos, usernameYPos, loveActionBtnWidth, 16.0)];
        [loveActionBtn setBackgroundColor:[UIColor clearColor]];
        [loveActionBtn addTarget:self action:@selector(loveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [loveActionBtn setImage:[UIImage imageNamed:@"photo-love-button.png"] forState:UIControlStateNormal];
        [loveActionBtn setImage:[UIImage imageNamed:@"photo-love-button-on.png"] forState:UIControlStateHighlighted];
        [loveActionBtn setImage:[UIImage imageNamed:@"photo-love-button-on.png"] forState:UIControlStateSelected];
        
        [loveActionBtn setImage:[UIImage imageNamed:@"photo-love-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
        
        CGFloat loveActionWidth = loveActionBtn.frame.size.width;
        
        self.loveBtn = loveActionBtn;
        
		[self addSubview:self.loveBtn];
        
        if (self.isLoved) {
            
            [self.loveBtn setSelected:YES];
            [self.loveBtn setHighlighted:NO];
        }
        
        
        // FLIP BUTTON
        btnXPos += (loveActionWidth + 5.0);
		CGFloat flipYPos = topActionsBtnYPos;
		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[flipButton setFrame:CGRectMake(btnXPos, flipYPos, 25.0, 16.0)];
		
        
        [flipButton setImage:[UIImage imageNamed:@"photo-flip-to-back-button.png"] forState:UIControlStateNormal];
        //[flipButton setImage:[UIImage imageNamed:@"photo-flip-to-front-button.png"] forState:UIControlStateHighlighted];
        [flipButton setImage:[UIImage imageNamed:@"photo-flip-to-front-button.png"] forState:UIControlStateSelected];
        
		[flipButton addTarget:self action:@selector(flipPhoto) forControlEvents:UIControlEventTouchUpInside];
		[flipButton.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
        self.flipBtn = flipButton;
        
		[self addSubview:self.flipBtn];
        //[self.flipBtn release];
        
        
		
		/*
         STRUCTURE
		 
         First layer is a UIView that acts as
         the container of all the photo area.
         With this (containerView) are two main views -
         photoView and actionsView. The latter refers
         to a view that contains everything for the 'back'
         of the photo.
         */
		
		CGRect cvFrame = CGRectMake(9.0, CONTAINER_START_POINT, MAIN_WIDTH, 302.0);
		UIView *cv = [[UIView alloc] initWithFrame:cvFrame];
		[cv setBackgroundColor:[UIColor clearColor]];
		self.containerView = cv;
		
		[self addSubview:self.containerView];
		
        
		CGRect cFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, 708.0);
		UIView *c = [[UIView alloc] initWithFrame:cFrame];
		[c setBackgroundColor:[UIColor clearColor]];
		self.photoView = c;
		
		[self.containerView addSubview:self.photoView];
        
        
        /*
         IMAGE DISPLAY
		 
         UIImageView for the polaroid image artwork, with
         a TAPhotoView on top of that as our placeholder
         for the actual image that is being downloaded
         to be placed into.
         */
		
		CGRect polaroidFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIImageView *polaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
		[self.photoView addSubview:polaroidBG];
		
		
		// MAIN IMAGE VIEW
		CGRect iViewFrame = CGRectMake(10.0, 10.0, 280.0, 280.0);
		TAPhotoView *iView = [[TAPhotoView alloc] initWithFrame:iViewFrame];
		[iView setBackgroundColor:[UIColor blackColor]];
		self.imageView = iView;
		
		[self.photoView addSubview:self.imageView];
		
		
		/*
         PROGRESS INDICATOR
		 
         Progress Indicator is a property as it needs
         to be updated regularly as the main image download
         is progressing.
         */
		CGRect imageViewFrame = self.imageView.frame;
		CGFloat progressXPos = imageViewFrame.origin.x + ((imageViewFrame.size.width/2.0) - 75.0);
		CGFloat progressYPos = imageViewFrame.origin.y + ((imageViewFrame.size.height/2.0) - 4.0);
		CGRect progressFrame = CGRectMake(progressXPos, progressYPos, 150.0, 9.0);
        
		UIProgressView *tmpProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
		[tmpProgressView setFrame:progressFrame];
        
        self.progressView = tmpProgressView;
        
		[self.photoView addSubview:self.progressView];
        
        
        
        
		// ACTIONS VIEW
		CGRect avFrame = CGRectMake(0.0, 0.0, MAIN_WIDTH, MAIN_HEIGHT);
		UIView *av = [[UIView alloc] initWithFrame:avFrame];
        [av setBackgroundColor:[UIColor clearColor]];
        
		self.actionsView = av;
        
		UIImageView *actionsPolaroidBG = [[UIImageView alloc] initWithFrame:polaroidFrame];
		[polaroidBG setImage:[UIImage imageNamed:@"polaroid-bg-main.png"]];
		
        [self.actionsView addSubview:actionsPolaroidBG];
        
        
        // beige details background
        CGRect beigeFrame = CGRectMake(10.0, 10.0, 280.0, 280.0);
		UIView *beigeBG = [[UIView alloc] initWithFrame:beigeFrame];
        [beigeBG setBackgroundColor:[UIColor colorWithRed:238.0/255.0 green:233.0/255.0 blue:229.0/255.0 alpha:1.0]];
        
		[self.actionsView addSubview:beigeBG];
        
        
        [self populateActionsView:photo];
		
		
		// IMAGE URL
		self.urlString = [photo url];

        
		// CAPTION
		CGFloat labelYPos = 325.0;
		UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(11.0, labelYPos, MAIN_WIDTH, 17.0)];
		[captionLabel setText:[photo caption]];
		[captionLabel setBackgroundColor:[UIColor clearColor]];
        [captionLabel setFont:[UIFont systemFontOfSize:12.0]];
		[self addSubview:captionLabel];
        
        
		// LOCATION TITLE
		CGFloat locationYPos = 342.0;
        CGFloat locationBtnXPos = 11.0;
        NSString *locationTitle = [photo.venue title];
        if ([locationTitle length] == 0) locationTitle = @"[untitled]";
        
        CGSize locationSize = [locationTitle sizeWithFont:[UIFont boldSystemFontOfSize:9.0]];
        
		UIButton *locationTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[locationTitleBtn setFrame:CGRectMake(11.0, locationYPos, 13 + locationSize.width, 16.0)];
        [locationTitleBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [locationTitleBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [locationTitleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [locationTitleBtn setImage:[UIImage imageNamed:@"photo-map-marker-icon.png"] forState:UIControlStateNormal];
		[locationTitleBtn setTitle:locationTitle forState:UIControlStateNormal];
        [locationTitleBtn setBackgroundColor:[UIColor clearColor]];
		[locationTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[locationTitleBtn addTarget:self action:@selector(locationTitleTapped) forControlEvents:UIControlEventTouchUpInside];
		[locationTitleBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
		[self addSubview:locationTitleBtn];
        
        CGFloat locationWidth = 13 + locationSize.width;
        
        
		// TAG TITLE
        CGFloat tagBtnXPos = locationBtnXPos + locationWidth + 10.0;
        NSString *tagTitle = [photo.tag title];
        
        CGSize tagSize = [tagTitle sizeWithFont:[UIFont boldSystemFontOfSize:9.0]];
        
		UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[tagBtn setFrame:CGRectMake(tagBtnXPos, locationYPos, 14 + tagSize.width, 16.0)];
        [tagBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [tagBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [tagBtn setImage:[UIImage imageNamed:@"photo-tag-icon.png"] forState:UIControlStateNormal];
		
        [tagBtn setBackgroundColor:[UIColor clearColor]];
		
		[tagBtn addTarget:self action:@selector(tagTitleTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[tagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
		[self addSubview:tagBtn];
	}
	
	return self;
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
        
        self.imageView.image = image;
    }
}


// Flips the containerView depending on whether
// the actionsView or photoView is currently
// being viewed
- (void)flipPhoto {
    
    if (viewingBack) {
        
        viewingBack = NO;
        self.photoView.hidden = NO;
        
        [self.flipBtn setSelected:NO];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:[self containerView]
                                 cache:YES];
        [UIView setAnimationDidStopSelector:@selector(flipComplete:finished:context:)];
        
        [[self actionsView] removeFromSuperview];
        [UIView commitAnimations];
    }
    
    else {
        
        viewingBack = YES;
        self.actionsView.hidden = NO;
        
        [self.flipBtn setSelected:YES];
    
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:[self containerView]
                                 cache:YES];
        [UIView setAnimationDidStopSelector:@selector(flipComplete:finished:context:)];
        
        [[self containerView] addSubview:self.actionsView];
        [UIView commitAnimations];
    }
}


// callback method for flipPhoto
- (void)flipComplete:(NSString*)animationID finished:(NSNumber*)finished
             context:(void*)context {

    if (viewingBack) self.photoView.hidden = YES;
    else self.actionsView.hidden = YES;
}



#pragma ACTIONS #############################################

- (void)usernameTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate usernameButtonTapped];
}

- (void)loveButtonTapped:(id)sender {
	
	// pass info on to delegate
	[self.delegate loveButtonTapped:self.imageID];
}

- (void)tweetButtonTapped {
    
	[self.delegate tweetButtonTapped:self.imageID];
}

- (void)facebookButtonTapped {
    
	[self.delegate facebookButtonTapped:self.imageID];
}

- (void)recommendButtonTapped {

    [self.delegate recommendButtonTapped];
}

- (void)flagButtonTapped {
    
    [self.delegate flagButtonTapped:self.imageID];
}

- (void)addToGuideButtonTapped {

    [self.delegate addPhotoToGuide:self.imageID];
}

- (void)locationTitleTapped {

    [self.delegate mapButtonTapped:self.imageID];
}

- (void)tagTitleTapped {

    [self.delegate tagButtonTapped:self.selectedTagID];
}


// OTHER

- (void)updateLoveButton:(BOOL)loved {
    
    self.isLoved = loved;
    
    if (self.isLoved) {
        
        [self.loveBtn setSelected:YES];
        [self.loveBtn setHighlighted:NO];
    }
    else {
        
        [self.loveBtn setSelected:NO];
        [self.loveBtn setHighlighted:NO];
    }
}

- (void)populateActionsView:(Photo *)photo {

    CGFloat dataLabelWidth = 57.0;
    CGFloat dataLabelXPos = 19.0;
    UIFont  *labelFont = [UIFont systemFontOfSize:11.0];
    UIColor *labelColor = [UIColor colorWithRed:165.0/255.0 green:163.0/255.0 blue:160.0/255.0 alpha:1.0];
    UIColor *textLabelColor = [UIColor blackColor];
    CGFloat labelYPos = 26.0;
    CGFloat labelHeight = 19.0;
    CGFloat labelPadding = 2.0;
    
    CGFloat textLabelXPos = 90.0;
    CGFloat textLabelMaxWidth = 165.0;
    
    CGFloat btnHorizontalPadding = 3.0;
    
    CGFloat borderWidth = 260.0;
    
    UIImage *borderImage = [UIImage imageNamed:@"metadata-border.png"];
    CGRect borderFrame = CGRectMake(dataLabelXPos, labelYPos, borderWidth, borderImage.size.height);
    UIImageView *border = [[UIImageView alloc] initWithFrame:borderFrame];
    [border setImage:borderImage];
    [self.actionsView addSubview:border];
    
    
    // PLACE ////////////////////////////////////////////
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+6.0), dataLabelWidth, labelHeight)];
    [placeLabel setText:@"PLACE"];
    [placeLabel setBackgroundColor:[UIColor clearColor]];
    [placeLabel setTextColor:labelColor];
    [placeLabel setFont:labelFont];
    [placeLabel sizeToFit];
    
    [self.actionsView addSubview:placeLabel];
    
    
    NSString *locationTitle = [photo.venue title];
    if ([locationTitle length] == 0) locationTitle = @"[untitled]";
    
    UILabel *textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+6.0), textLabelMaxWidth, labelHeight)];
    [textPlaceLabel setText:locationTitle];
    [textPlaceLabel setBackgroundColor:[UIColor clearColor]];
    [textPlaceLabel setTextColor:textLabelColor];
    [textPlaceLabel setFont:labelFont];
    [textPlaceLabel sizeToFit];
    
    [self.actionsView addSubview:textPlaceLabel];
    
    // PLACE END ////////////////////////////////////////////
    

    labelYPos += labelHeight + labelPadding;
    labelHeight = 19.0;
    
    UIImageView *border22 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border22 setImage:borderImage];
    [self.actionsView addSubview:border22];
    

    // CAPTION ////////////////////////////////////////////
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+6.0), dataLabelWidth, labelHeight)];
    [captionLabel setText:@"CAPTION"];
    [captionLabel setBackgroundColor:[UIColor clearColor]];
    [captionLabel setTextColor:labelColor];
    [captionLabel setFont:labelFont];
    [captionLabel sizeToFit];
    
    [self.actionsView addSubview:captionLabel];
    
    
    UILabel *textCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+6.0), textLabelMaxWidth, labelHeight)];
    [textCaptionLabel setText:[photo caption]];
    [textCaptionLabel setBackgroundColor:[UIColor clearColor]];
    [textCaptionLabel setTextColor:textLabelColor];
    [textCaptionLabel setFont:labelFont];
    [textCaptionLabel sizeToFit];
    
    [self.actionsView addSubview:textCaptionLabel];
    
    // CAPTION END ////////////////////////////////////////////////
    
    
    labelYPos += labelHeight + labelPadding;
    labelHeight = 19.0;
    
    
    UIImageView *border2 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border2 setImage:borderImage];
    [self.actionsView addSubview:border2];
    
    // TAG
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+borderFrame.size.height), dataLabelWidth, labelHeight)];
    [tagLabel setText:@"ACTIVITY"];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    [tagLabel setTextColor:labelColor];
    [tagLabel setFont:labelFont];
    
    [self.actionsView addSubview:tagLabel];
    
    
    UILabel *textTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+borderFrame.size.height), textLabelMaxWidth, labelHeight)];
    [textTagLabel setText:[photo.tag title]];
    [textTagLabel setBackgroundColor:[UIColor clearColor]];
    [textTagLabel setTextColor:textLabelColor];
    [textTagLabel setFont:labelFont];
    
    [self.actionsView addSubview:textTagLabel];
    
    // TAG END ////////////////////////////////////////////
    
    labelYPos += labelHeight + labelPadding;
    
    UIImageView *border5 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border5 setImage:borderImage];
    [self.actionsView addSubview:border5];
    
    // LOCATION
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+borderFrame.size.height), dataLabelWidth, labelHeight)];
    [locationLabel setText:@"ADDRESS"];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [locationLabel setTextColor:labelColor];
    [locationLabel setFont:labelFont];
    
    [self.actionsView addSubview:locationLabel];
    
    UILabel *textLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+borderFrame.size.height), textLabelMaxWidth, labelHeight)];
    [textLocationLabel setText:photo.venue.address];
    [textLocationLabel setBackgroundColor:[UIColor clearColor]];
    [textLocationLabel setTextColor:textLabelColor];
    [textLocationLabel setFont:labelFont];
    
    [self.actionsView addSubview:textLocationLabel];
    
    // LOCATION END ////////////////////////////////////////////
    
    labelYPos += labelHeight + labelPadding;
    
    
    UIImageView *border3 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border3 setImage:borderImage];
    [self.actionsView addSubview:border3];
    
    // CITY
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+borderFrame.size.height), dataLabelWidth, labelHeight)];
    [cityLabel setText:@"CITY"];
    [cityLabel setBackgroundColor:[UIColor clearColor]];
    [cityLabel setTextColor:labelColor];
    [cityLabel setFont:labelFont];
    
    [self.actionsView addSubview:cityLabel];
    
    
    UILabel *textCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+borderFrame.size.height), textLabelMaxWidth, labelHeight)];
    [textCityLabel setText:[photo.city title]];
    [textCityLabel setBackgroundColor:[UIColor clearColor]];
    [textCityLabel setTextColor:textLabelColor];
    [textCityLabel setFont:labelFont];
    
    [self.actionsView addSubview:textCityLabel];
    
    // CITY END ////////////////////////////////////////////
    
    
    labelYPos += labelHeight + labelPadding;
    
    
    UIImageView *border4 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border4 setImage:borderImage];
    [self.actionsView addSubview:border4];
    
    
    // ADD PHOTO TO A GUIDE BUTTON
    
    CGFloat fullBtnWidth = 262.0;
    CGFloat fullBtnHeight = 37.0;
    CGFloat btnXPos = 19.0;
    CGFloat btnYPos = 140.0;
    CGFloat buttonPadding = 7.0;
    
    UIButton *addToGuideBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addToGuideBtn setFrame:CGRectMake(btnXPos, btnYPos, fullBtnWidth, fullBtnHeight)];
    
    [addToGuideBtn setImage:[UIImage imageNamed:@"photo-add-to-guide-button.png"] forState:UIControlStateNormal];
    [addToGuideBtn setImage:[UIImage imageNamed:@"photo-add-to-guide-button-on.png"] forState:UIControlStateHighlighted];
    
    [addToGuideBtn addTarget:self action:@selector(addToGuideButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionsView addSubview:addToGuideBtn];
    
    
    // FLAG BUTTON
    
    btnYPos += (fullBtnHeight + buttonPadding);
    
    UIButton *flagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flagBtn setFrame:CGRectMake(btnXPos, btnYPos, fullBtnWidth, fullBtnHeight)];
    
    [flagBtn setImage:[UIImage imageNamed:@"photo-flag-button.png"] forState:UIControlStateNormal];
    [flagBtn setImage:[UIImage imageNamed:@"photo-flag-button-on.png"] forState:UIControlStateHighlighted];
    
    [flagBtn addTarget:self action:@selector(flagButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionsView addSubview:flagBtn];
    
    
    btnYPos += (fullBtnHeight + buttonPadding);
    
    
    // SHADOW BORDER
    
    CGRect shadowBorderFrame = CGRectMake(10.0, btnYPos, 280.0, 1.0);
    UIImageView *shadowBorder = [[UIImageView alloc] initWithFrame:shadowBorderFrame];
    [shadowBorder setImage:[UIImage imageNamed:@"photo-details-shadow-border.png"]];
    
    [self.actionsView addSubview:shadowBorder];    
    
    
    // TWEET BUTTON
    fullBtnWidth = 42.0;
    fullBtnHeight = 42.0;
    
    btnYPos += (1.0 + buttonPadding);
    
    UIButton *tweetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [tweetBtn setFrame:CGRectMake(btnXPos, btnYPos, fullBtnWidth, fullBtnHeight)];
    
    [tweetBtn setImage:[UIImage imageNamed:@"tweet-photo-button.png"] forState:UIControlStateNormal];
    [tweetBtn setImage:[UIImage imageNamed:@"tweet-photo-button-on.png"] forState:UIControlStateHighlighted];
    [tweetBtn addTarget:self action:@selector(tweetButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionsView addSubview:tweetBtn];
    
    
    // FB Button
    btnXPos += (fullBtnWidth + btnHorizontalPadding);
    
    UIButton *facebookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [facebookBtn setFrame:CGRectMake(btnXPos, btnYPos, fullBtnWidth, fullBtnHeight)];
    
    [facebookBtn setImage:[UIImage imageNamed:@"facebook-photo-button.png"] forState:UIControlStateNormal];
    [facebookBtn setImage:[UIImage imageNamed:@"facebook-photo-button-on.png"] forState:UIControlStateHighlighted];
    [facebookBtn addTarget:self action:@selector(facebookButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionsView addSubview:facebookBtn];
    
    
    // Recommend Button
    btnXPos += (fullBtnWidth + btnHorizontalPadding);
    
    fullBtnWidth = 171.0;
    
    UIButton *recommendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [recommendBtn setFrame:CGRectMake(btnXPos, btnYPos, fullBtnWidth, fullBtnHeight)];
    
    [recommendBtn setImage:[UIImage imageNamed:@"recommend-photo-button.png"] forState:UIControlStateNormal];
    [recommendBtn setImage:[UIImage imageNamed:@"recommend-photo-button-on.png"] forState:UIControlStateHighlighted];
    [recommendBtn addTarget:self action:@selector(recommendButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionsView addSubview:recommendBtn];
}


@end
