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
#import <QuartzCore/QuartzCore.h>

#define MAIN_WIDTH 301
#define MAIN_HEIGHT 301
#define CONTAINER_START_POINT 47.0
#define SCROLL_COLUMN_WIDTH 272.0
#define SCROLL_COLUMN_PADDING 10
#define SCROLL_COLUMN_INNER_PADDING 14

#define ANIMATION_DURATION_SLOW 0.5
#define ANIMATION_DURATION_FAST 0.25

#define INNER_VIEW_TAG 8888

@implementation TAPhotoDetails


- (id)initWithFrame:(CGRect)frame forPhoto:(Photo *)photo loved:(BOOL)loved {
    
	self = [super initWithFrame:frame];
	
    if (self) {
		
        self.photo = photo;
		self.imageID = [photo photoID];
		self.selectedTag = [photo.tag title];
        self.isLoved = loved;
        self.selectedTagID = [photo.tag tagID];
        self.selectedCity = [photo.city title];
        
        CGFloat topActionsBtnYPos = 10.0;
        CGFloat usernameXPos = 52.0;
        CGFloat fontSize = 14.0;
        CGFloat topRightActionsXPos = 160.0;
        CGFloat btnXPos = topRightActionsXPos;
        CGFloat leftPadding = 10.0;
        UIFont *btnFont = [UIFont systemFontOfSize:13.0];
        
        
        // Avatar image view
        CGFloat avatarWidth = 30.0;
        CGFloat avatarHeight = 30.0;
		self.avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, topActionsBtnYPos, avatarWidth, avatarHeight)];
		[self.avatarView setBackgroundColor:[UIColor lightGrayColor]];
        self.avatarView.layer.cornerRadius = 3.0;
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
		[btn.titleLabel setFont:[UIFont fontWithName:@"FreightSansBold" size:14]];
		[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btn sizeToFit];
        
		[self addSubview:btn];
        
        
        // TIME ELAPSED BUTTON
        CGSize expectedLabelSize = [[photo timeElapsed] sizeWithFont:btnFont];
        
		UIButton *timeElapsedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[timeElapsedBtn setFrame:CGRectMake(usernameXPos, usernameYPos + 18, (13 + expectedLabelSize.width), 15.0)];
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
        
		[self addSubview:timeElapsedBtn];
        
        
        // LOVE ACTION BUTTON
        btnXPos = 199.0;
        CGFloat loveActionBtnWidth = 50.0;
        CGFloat loveActionBtnHeight = 30.0;
        
		UIButton *loveActionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[loveActionBtn setFrame:CGRectMake(btnXPos, usernameYPos, loveActionBtnWidth, loveActionBtnHeight)];
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
		[flipButton setFrame:CGRectMake(btnXPos, flipYPos, 50.0, 30.0)];
		
        
        [flipButton setImage:[UIImage imageNamed:@"photo-flip-to-back-button.png"] forState:UIControlStateNormal];
        //[flipButton setImage:[UIImage imageNamed:@"photo-flip-to-front-button.png"] forState:UIControlStateHighlighted];
        [flipButton setImage:[UIImage imageNamed:@"photo-flip-to-front-button.png"] forState:UIControlStateSelected];
        
		[flipButton addTarget:self action:@selector(flipPhoto) forControlEvents:UIControlEventTouchUpInside];
		[flipButton.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
        self.flipBtn = flipButton;
        
		[self addSubview:self.flipBtn];
        
        
		
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
        
        UIButton *mapMarkerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[mapMarkerBtn setFrame:CGRectMake(15.0, 348.0, 15.0, 22.0)];
        [mapMarkerBtn setImage:[UIImage imageNamed:@"big-map-marker-icon.png"] forState:UIControlStateNormal];
        [mapMarkerBtn setBackgroundColor:[UIColor clearColor]];
		[mapMarkerBtn addTarget:self action:@selector(locationTitleTapped) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:mapMarkerBtn];
        
		// LOCATION TITLE
		CGFloat locationYPos = 348.0;
        CGFloat locationBtnXPos = 28.0;
        NSString *locationTitle = [photo.venue title];
        if ([locationTitle length] == 0) locationTitle = @"[untitled]";
        
        CGSize locationSize = [locationTitle sizeWithFont:[UIFont fontWithName:@"FreightSansBold" size:13.0]];
        
		UIButton *locationTitleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[locationTitleBtn setFrame:CGRectMake(locationBtnXPos, locationYPos, 13 + locationSize.width, 16.0)];
		[locationTitleBtn setTitle:locationTitle forState:UIControlStateNormal];
        [locationTitleBtn setBackgroundColor:[UIColor clearColor]];
		[locationTitleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[locationTitleBtn addTarget:self action:@selector(locationTitleTapped) forControlEvents:UIControlEventTouchUpInside];
		[locationTitleBtn.titleLabel setFont:[UIFont fontWithName:@"FreightSansBold" size:13.0]];
        
		[self addSubview:locationTitleBtn];
                
        
		// TAG TITLE
        CGFloat tagBtnXPos = locationBtnXPos;
        CGFloat tagBtnYPos = locationYPos + 10.0;
        NSString *tagTitle = [photo.tag title];
        
        CGSize tagSize = [tagTitle sizeWithFont:[UIFont boldSystemFontOfSize:9.0]];
        
		UIButton *tagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		[tagBtn setFrame:CGRectMake(tagBtnXPos, tagBtnYPos, 14 + tagSize.width, 16.0)];
//        [tagBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
//        [tagBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
//        [tagBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//        [tagBtn setImage:[UIImage imageNamed:@"photo-tag-icon.png"] forState:UIControlStateNormal];
		
        [tagBtn setBackgroundColor:[UIColor clearColor]];
		
		[tagBtn addTarget:self action:@selector(tagTitleTapped) forControlEvents:UIControlEventTouchUpInside];
        
        [tagBtn setTitle:tagTitle forState:UIControlStateNormal];
        [tagBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		[tagBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:9.0]];
        
		[self addSubview:tagBtn];
        
        
        // LOVES BUTTON
        CGFloat lovesBtnXPos = 265.0;
        CGSize expectedLovesSize = [[NSString stringWithFormat:@"%i", [photo.lovesCount intValue]] sizeWithFont:btnFont];
        
		self.lovesCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.lovesCountButton setFrame:CGRectMake(lovesBtnXPos, locationYPos, (14+expectedLovesSize.width), 15.0)];
        [self.lovesCountButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
        [self.lovesCountButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
        [self.lovesCountButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        
        [self.lovesCountButton setBackgroundColor:[UIColor clearColor]];
		[self.lovesCountButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.lovesCountButton.titleLabel setFont:btnFont];
        [self.lovesCountButton setImage:[UIImage imageNamed:@"photo-loves-icon.png"] forState:UIControlStateNormal];
        
        [self.lovesCountButton setTitle:[NSString stringWithFormat:@"%i", [photo.lovesCount intValue]] forState:UIControlStateNormal];
        
        [self.lovesCountButton setEnabled:NO];
        [self.lovesCountButton setAdjustsImageWhenDisabled:NO];
        
		[self addSubview:self.lovesCountButton];
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
    
    self.isLoved = !self.isLoved;	
    
    if (self.isLoved) {
        
        [self.loveBtn setSelected:YES];
        [self.loveBtn setHighlighted:NO];
    }
    else {
        
        [self.loveBtn setSelected:NO];
        [self.loveBtn setHighlighted:NO];
    }

    [self updateLovesCountLabel];
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
    CGFloat labelYPos = 18.0;
    CGFloat labelHeight = 22.0;
    CGFloat labelPadding = 2.0;
    
    CGFloat textLabelXPos = 90.0;
    CGFloat textLabelMaxWidth = 190.0;
    
    CGFloat btnHorizontalPadding = 3.0;
    
    CGFloat borderWidth = 260.0;
    
    UIImage *borderImage = [UIImage imageNamed:@"metadata-border.png"];
    CGRect borderFrame = CGRectMake(dataLabelXPos, labelYPos, borderWidth, borderImage.size.height);
    
    
    // PLACE ////////////////////////////////////////////
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, labelYPos, dataLabelWidth, labelHeight)];
    [placeLabel setText:@"PLACE"];
    [placeLabel setBackgroundColor:[UIColor clearColor]];
    [placeLabel setTextColor:labelColor];
    [placeLabel setFont:labelFont];
    
    [self.actionsView addSubview:placeLabel];
    
    
    NSString *locationTitle = [photo.venue title];
    if ([locationTitle length] == 0) locationTitle = @"[untitled]";
    
    UILabel *textPlaceLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, labelYPos, textLabelMaxWidth, labelHeight)];
    [textPlaceLabel setText:locationTitle];
    [textPlaceLabel setBackgroundColor:[UIColor clearColor]];
    [textPlaceLabel setTextColor:textLabelColor];
    [textPlaceLabel setFont:labelFont];
    
    [self.actionsView addSubview:textPlaceLabel];
    
    // PLACE END ////////////////////////////////////////////
    
    labelYPos += labelHeight;
    
    UIImageView *border22 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border22 setImage:borderImage];
    [self.actionsView addSubview:border22];
    

    // CAPTION ////////////////////////////////////////////
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+labelPadding), dataLabelWidth, labelHeight)];
    [captionLabel setText:@"CAPTION"];
    [captionLabel setBackgroundColor:[UIColor clearColor]];
    [captionLabel setTextColor:labelColor];
    [captionLabel setFont:labelFont];
    
    [self.actionsView addSubview:captionLabel];
    
    
    UILabel *textCaptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+labelPadding), textLabelMaxWidth, labelHeight)];
    
    NSString *captionStr = [photo caption];
    if (captionStr.length == 0) captionStr = @"-";
    
    [textCaptionLabel setText:captionStr];
    [textCaptionLabel setNumberOfLines:0];
    [textCaptionLabel setBackgroundColor:[UIColor clearColor]];
    [textCaptionLabel setTextColor:textLabelColor];
    [textCaptionLabel setFont:labelFont];
    textCaptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGSize labelsize = [[photo caption] sizeWithFont:labelFont constrainedToSize:CGSizeMake(textLabelMaxWidth, 28) lineBreakMode:UILineBreakModeWordWrap];
    textCaptionLabel.frame=CGRectMake(textLabelXPos, (labelYPos+labelPadding+4.0), textLabelMaxWidth, labelsize.height);
    
    [self.actionsView addSubview:textCaptionLabel];
    
    // CAPTION END ////////////////////////////////////////////////
    
    
    labelYPos = CGRectGetMaxY(textCaptionLabel.frame) + 4.0;
    
    
    UIImageView *border2 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border2 setImage:borderImage];
    [self.actionsView addSubview:border2];
    
    // TAG
    UILabel *tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos + labelPadding), dataLabelWidth, labelHeight)];
    [tagLabel setText:@"ACTIVITY"];
    [tagLabel setBackgroundColor:[UIColor clearColor]];
    [tagLabel setTextColor:labelColor];
    [tagLabel setFont:labelFont];
    
    [self.actionsView addSubview:tagLabel];
    
    
    UILabel *textTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos + labelPadding), textLabelMaxWidth, labelHeight)];
    [textTagLabel setText:[photo.tag title]];
    [textTagLabel setBackgroundColor:[UIColor clearColor]];
    [textTagLabel setTextColor:textLabelColor];
    [textTagLabel setFont:labelFont];
    
    [self.actionsView addSubview:textTagLabel];
    
    // TAG END ////////////////////////////////////////////
    
    labelYPos += (labelPadding+labelHeight);
    
    UIImageView *border5 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border5 setImage:borderImage];
    [self.actionsView addSubview:border5];
    
    // LOCATION
    UILabel *locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+labelPadding), dataLabelWidth, labelHeight)];
    [locationLabel setText:@"ADDRESS"];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    [locationLabel setTextColor:labelColor];
    [locationLabel setFont:labelFont];
    
    [self.actionsView addSubview:locationLabel];
    
    UILabel *textLocationLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+labelPadding), textLabelMaxWidth, labelHeight)];
    
    NSString *addressStr = photo.venue.address;
    if ([addressStr isEqualToString:@"<null>"] || addressStr.length == 0) addressStr = @"-";
    
    [textLocationLabel setText:addressStr];
    [textLocationLabel setBackgroundColor:[UIColor clearColor]];
    [textLocationLabel setTextColor:textLabelColor];
    [textLocationLabel setFont:labelFont];
    
    [self.actionsView addSubview:textLocationLabel];
    
    // LOCATION END ////////////////////////////////////////////
    
    labelYPos += (labelPadding+labelHeight);
    
    
    UIImageView *border3 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border3 setImage:borderImage];
    [self.actionsView addSubview:border3];
    
    // CITY
    UILabel *cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(dataLabelXPos, (labelYPos+labelPadding), dataLabelWidth, labelHeight)];
    [cityLabel setText:@"CITY"];
    [cityLabel setBackgroundColor:[UIColor clearColor]];
    [cityLabel setTextColor:labelColor];
    [cityLabel setFont:labelFont];
    
    [self.actionsView addSubview:cityLabel];
    
    
    UILabel *textCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(textLabelXPos, (labelYPos+labelPadding), textLabelMaxWidth, labelHeight)];
    [textCityLabel setText:[photo.city title]];
    [textCityLabel setBackgroundColor:[UIColor clearColor]];
    [textCityLabel setTextColor:textLabelColor];
    [textCityLabel setFont:labelFont];
    
    [self.actionsView addSubview:textCityLabel];
    
    // CITY END ////////////////////////////////////////////
    
    
    labelYPos += (labelPadding+labelHeight);
    
    
    UIImageView *border4 = [[UIImageView alloc] initWithFrame:CGRectMake(borderFrame.origin.x, labelYPos, borderWidth, borderFrame.size.height)];
    [border4 setImage:borderImage];
    [self.actionsView addSubview:border4];
    
    
    // ADD PHOTO TO A GUIDE BUTTON
    
    CGFloat fullBtnWidth = 262.0;
    CGFloat fullBtnHeight = 37.0;
    CGFloat btnXPos = 19.0;
    CGFloat btnYPos = 150.0;
    CGFloat buttonPadding = 4.0;
    
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

- (void)updateLovesCountLabel {

    [self.lovesCountButton setTitle:[NSString stringWithFormat:@"%i", [self.photo.lovesCount intValue]] forState:UIControlStateNormal];
}


@end
