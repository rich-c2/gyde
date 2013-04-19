//
//  TAGuideDetailsVC.m
//  Tourism App
//
//  Created by Richard Lee on 28/08/12.
//  Copyright (c) 2012 C2 Media Pty Ltd. All rights reserved.
//

#import "TAGuideDetailsVC.h"
#import "AppDelegate.h"
#import "HTTPFetcher.h"
#import "JSONKit.h"
#import "SVProgressHUD.h"
#import "GridImage.h"
#import "TAProfileVC.h"
#import "TAImageDetailsVC.h"
#import "TAMapVC.h"
#import "MyMapAnnotation.h"
#import "TAPhotoTableCell.h"
#import "TAScrollVC.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"
#import <Accounts/Accounts.h>
#import <QuartzCore/QuartzCore.h>

#define IMAGE_VIEW_TAG 7000
#define GRID_IMAGE_WIDTH 75.0
#define GRID_IMAGE_HEIGHT 75.0
#define IMAGE_PADDING 4.0


@interface TAGuideDetailsVC ()

@end

@implementation TAGuideDetailsVC

@synthesize loveBtn = _loveBtn;
@synthesize guideMode, photos, guideID, gridScrollView, guideData, guideMap;
@synthesize titleLabel, authorBtn, imagesView, photosTable, loadCell, guideThumb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
    
    self.title = @"GUIDE";
    self.navigationController.navigationBarHidden = NO;
    
    self.photosTable.backgroundColor = [UIColor clearColor];
    self.photosTable.backgroundView = nil;
	
	self.photos = [NSMutableArray array];
	self.guideData = [NSDictionary dictionary];
	
	// Added interactive states for buttons ///////////////////////////////////////////////////
    [self.loveBtn setImage:[UIImage imageNamed:@"guide-love-button-on.png"] forState:(UIControlStateHighlighted|UIControlStateSelected|UIControlStateDisabled)];
    
    // Table header view
    [self setupTableHeader];
    
    // Add single tap gesture recognizer to map view
    // The action will be goToMapDetails:
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(goToMapDetails:)];
    tgr.numberOfTapsRequired = 1;
    tgr.numberOfTouchesRequired = 1;
    [self.guideMap addGestureRecognizer:tgr];
    
}


#pragma mark - Private Methods
- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload {
	
	self.guideID = nil;
	self.photos = nil;
	self.guideData = nil;
	self.guideThumb = nil;
	
    self.imagesView = nil;
    self.authorBtn = nil;
    self.titleLabel = nil;
	
	self.gridScrollView = nil;
		
    self.guideMap = nil;
	
	self.photosTable = nil;
	
    [self setLoveBtn:nil];
    [self setPhotosCountBtn:nil];
    [self setTimeElapsedBtn:nil];
    
    self.postParams = nil;
    
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated {
	
    [super viewDidAppear:animated];
	
	if (!guideLoaded && !loading) {
		
		// Fetch the guide data
		[self getGuide];
		
		[self initIsLovedAPI];
	}
	
	//[self.photosTable deselectRowAtIndexPath:[self.photosTable indexPathForSelectedRow] animated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    CGRect headerFrame = CGRectMake(0, 0, 320, 25);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 25.0)];
    bgView.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    bgView.layer.cornerRadius = 0.0;
    bgView.alpha = 0.25;
    [headerView addSubview:bgView];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18.0, 0.0, 298, 25.0)];
    self.headerLabel.textColor = [UIColor whiteColor];
    self.headerLabel.backgroundColor = [UIColor clearColor];
    self.headerLabel.font = [UIFont fontWithName:@"FreightSansBold" size:11];
    self.headerLabel.text = [NSString stringWithFormat:@"PLACES (%i)", self.photos.count];
    [headerView addSubview:self.headerLabel];

    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

    return 25.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [self.photos count];
}


- (void)configureCell:(TAPhotoTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	
    
    // Make sure the cell images don't scale
    [cell.backgroundView setContentMode:UIViewContentModeTop];
    [cell.selectedBackgroundView setContentMode:UIViewContentModeTop];
    
	Photo *photo = [self.photos objectAtIndex:[indexPath row]];

	NSString *title = photo.venue.title;
	if ([title length] == 0) title = @"[untitled]";
	
	[cell.titleLabel setText:title];
    
    [cell.subtitleLabel setText:photo.timeElapsed];
	
	[cell initImage:photo.thumbURL];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    TAPhotoTableCell *cell = (TAPhotoTableCell *)[tableView dequeueReusableCellWithIdentifier:[TAPhotoTableCell reuseIdentifier]];
	
	if (cell == nil) {
		
		[[NSBundle mainBundle] loadNibNamed:@"TAPhotoTableCell" owner:self options:nil];
        cell = loadCell;
        self.loadCell = nil;
	}
	
	// Retrieve Track object and set it's name to the cell
	[self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// Retrieve the User object at the given index that's in self.users
	Photo *photo = [self.photos objectAtIndex:[indexPath row]];		
	
	// Push the TAScrollVC onto the stack
	TAScrollVC *horizotalScroll = [[TAScrollVC alloc] initWithNibName:@"TAScrollVC" bundle:nil];
	[horizotalScroll setPhotos:self.photos];
	[horizotalScroll setSelectedPhotoID:[photo photoID]];
	
	[self.navigationController pushViewController:horizotalScroll animated:YES];
}


#pragma MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
    if ([annotation isKindOfClass:[MKUserLocation class]])
		return nil;		
	
	static NSString * const kPinAnnotationIdentifier = @"PinIdentifier";
	
	MKPinAnnotationView* pinView;
	
    if ([annotation isKindOfClass:[MyMapAnnotation class]]) {
		
		// try to dequeue an existing pin view first
        static NSString* annotationIdentifier = @"annotationIdentifier";
        pinView = (MKPinAnnotationView *)
		[self.guideMap dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
		
		if (!pinView) {
			
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kPinAnnotationIdentifier];
			
			[pinView setUserInteractionEnabled:YES];
			[pinView setCanShowCallout:YES];
		}
	}
	
	return pinView;
}


#pragma RecommendsDelegate methods

- (void)recommendToUsernames:(NSMutableArray *)usernames {
		
	// Retain the usernames that were selected 
	// for this Guide to be recommend to
	[self initRecommendAPI:usernames];
}


#pragma GridImageDelegate methods 

- (void)gridImageButtonClicked:(NSInteger)viewTag {
	
	NSDictionary *image = [self.photos objectAtIndex:(viewTag - IMAGE_VIEW_TAG)];
	
	// Push the Image Details VC onto the stack
	TAImageDetailsVC *imageDetailsVC = [[TAImageDetailsVC alloc] initWithNibName:@"TAImageDetailsVC" bundle:nil];
	[imageDetailsVC setImageCode:[image objectForKey:@"code"]];
	
	[self.navigationController pushViewController:imageDetailsVC animated:YES];
}


#pragma MY-METHODS

- (void)setupTableHeader {

    CGFloat headerHeight = 202;
    CGFloat mapHeight = 100;
    CGRect mapFrame = CGRectMake(0, 0, 320, mapHeight);
    CGRect headerFrame = CGRectMake(0, 0, 320, headerHeight);
    
    CGFloat titleXPos = 11.0;
    CGFloat titleYPos = 104.0;
    CGFloat subHeadingYPos = 124.0;
    
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    
    self.guideMap = [[MKMapView alloc] initWithFrame:mapFrame];
    
    [headerView addSubview:self.guideMap];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleXPos, titleYPos, 298, 30)];
    self.titleLabel.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont fontWithName:@"FreightSansMedium" size:23];
    [headerView addSubview:self.titleLabel];
    
    self.loveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loveBtn.backgroundColor = [UIColor clearColor];
    self.loveBtn.frame = CGRectMake(282, titleYPos+10, 30, 30);
    [self.loveBtn addTarget:self action:@selector(loveButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.loveBtn setImage:[UIImage imageNamed:@"guide-love-button.png"] forState:UIControlStateNormal];
    [self.loveBtn setImage:[UIImage imageNamed:@"guide-love-button-on.png"] forState:UIControlStateHighlighted];
    [headerView addSubview:self.loveBtn];
    
    self.authorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.authorBtn.backgroundColor = [UIColor clearColor];
    [self.authorBtn setTitleColor:[UIColor colorWithRed:142.0/255.0 green:140.0/255.0 blue:136.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.authorBtn.titleLabel.font = [UIFont fontWithName:@"FreightSansBold" size:13];
    self.authorBtn.frame = CGRectMake(titleXPos, subHeadingYPos, 60, 30);
    [self.authorBtn addTarget:self action:@selector(authorButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:self.authorBtn];
    
    self.photosCountBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photosCountBtn.backgroundColor = [UIColor clearColor];
    [self.photosCountBtn setTitleColor:[UIColor colorWithRed:142.0/255.0 green:140.0/255.0 blue:136.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.photosCountBtn.titleLabel.font = [UIFont fontWithName:@"FreightSansBold" size:13];
    self.photosCountBtn.frame = CGRectMake(titleXPos + 70, subHeadingYPos, 100, 30);
    [headerView addSubview:self.photosCountBtn];
    
    self.timeElapsedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.timeElapsedBtn.backgroundColor = [UIColor clearColor];
    [self.timeElapsedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.timeElapsedBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.timeElapsedBtn setTitleColor:[UIColor colorWithRed:142.0/255.0 green:140.0/255.0 blue:136.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.timeElapsedBtn.titleLabel.font = [UIFont fontWithName:@"FreightSansBold" size:13];
    self.timeElapsedBtn.frame = CGRectMake((titleXPos + (70 * 2)), subHeadingYPos, 100, 30);
    
    [self.timeElapsedBtn setImage:[UIImage imageNamed:@"photo-time-icon.png"] forState:UIControlStateNormal];
   
    [headerView addSubview:self.timeElapsedBtn];
    
    CGRect descFrame = CGRectMake(titleXPos, subHeadingYPos + 26, 298, 46);
    self.descriptionView = [[UITextView alloc] initWithFrame:descFrame];
    self.descriptionView.editable = NO;
    self.descriptionView.showsHorizontalScrollIndicator = NO;
    self.descriptionView.showsVerticalScrollIndicator = NO;
    self.descriptionView.contentInset = UIEdgeInsetsMake(-8, -8, 0, 0);
    self.descriptionView.textColor = [UIColor colorWithRed:142.0/255.0 green:140.0/255.0 blue:136.0/255.0 alpha:1.0];
    self.descriptionView.font = [UIFont systemFontOfSize:10];
    self.descriptionView.backgroundColor = [UIColor clearColor];
    self.descriptionView.scrollEnabled = NO;
    [headerView addSubview:self.descriptionView];
    
    
    self.photosTable.tableHeaderView = headerView;
}


- (void)imageLoaded:(UIImage *)image withURL:(NSURL *)url {
	
	NSArray *cells = [self.photosTable visibleCells];
//    [cells retain];
    SEL selector = @selector(imageLoaded:withURL:);
	
    for (int i = 0; i < [cells count]; i++) {
		
		UITableViewCell* c = [cells objectAtIndex: i];
        if ([c respondsToSelector:selector]) {
            [c performSelector:selector withObject:image withObject:url];
        }
//        [c release];
		c = nil;
    }
	
//    [cells release];
}


- (void)updateImageGrid {
	
	CGFloat gridWidth = self.imagesView.frame.size.width;
	CGFloat maxXPos = gridWidth - GRID_IMAGE_WIDTH;
	
	CGFloat startXPos = 0.0;
	CGFloat xPos = startXPos;
	CGFloat yPos = 0.0;
	
	// Number of new rows to add, and how many have already
	// been added previously
	NSInteger subviewsCount = [self.imagesView.subviews count];
	
	// Set what the next tag value should be
	NSInteger tagCounter = IMAGE_VIEW_TAG + subviewsCount;
	
	// If images have previously been added, calculate where to 
	// start placing the next batch of images
	if (subviewsCount > 0) {
		
		NSInteger rowCount = subviewsCount/4;
		NSInteger leftOver = subviewsCount%4;
		
		// Calculate starting xPos & yPos
		xPos = (leftOver * (GRID_IMAGE_WIDTH + IMAGE_PADDING));
		yPos = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	}
	
	for (int i = subviewsCount; i < [self.photos count]; i++) {
		
		// Retrieve Image object from array, and construct
		// a URL string for the thumbnail image
		Photo *photo = [self.photos objectAtIndex:i];
		NSString *thumbURL = [photo thumbURL];
		
		// Create GridImage, set its Tag and Delegate, and add it 
		// to the imagesView
		CGRect newFrame = CGRectMake(xPos, yPos, GRID_IMAGE_WIDTH, GRID_IMAGE_HEIGHT);
		GridImage *gridImage = [[GridImage alloc] initWithFrame:newFrame imageURL:thumbURL];
		[gridImage setTag:tagCounter];
		[gridImage setDelegate:self];
		[self.imagesView addSubview:gridImage];
		
		// Update xPos & yPos for new image
		xPos += (GRID_IMAGE_WIDTH + IMAGE_PADDING);
		
		// Update tag for next image
		tagCounter++;
		
		if (xPos > maxXPos) {
			
			xPos = startXPos;
			yPos += (GRID_IMAGE_HEIGHT + IMAGE_PADDING);
		}
	}
	
	// Update size of the relevant views
	[self updateGridLayout];
}


- (void)updateGridLayout {
	
	// Updated number of how many rows there are
	NSInteger rowCount = [[self.imagesView subviews] count]/4;
	NSInteger leftOver = [[self.imagesView subviews] count]%4;
	if (leftOver > 0) rowCount++;
	
	// Update the scroll view's content height
	CGRect imagesViewFrame = self.imagesView.frame;
	CGFloat gridRowsHeight = (rowCount * (GRID_IMAGE_HEIGHT + IMAGE_PADDING));
	CGFloat sViewContentHeight = imagesViewFrame.origin.y + gridRowsHeight + IMAGE_PADDING;
	
	// Set image view frame height
	imagesViewFrame.size.height = gridRowsHeight;
	[self.imagesView setFrame:imagesViewFrame];
	
	// Adjust content height of the scroll view
	[self.gridScrollView setContentSize:CGSizeMake(self.gridScrollView.frame.size.width, sViewContentHeight)];
}


- (void)getGuide {
		
    NSDictionary *params = @{ @"username" : [self appDelegate].loggedInUsername, @"guideID" : [self guideID], @"token" : [[self appDelegate] sessionToken] };
    
    [[GlooRequestManager sharedManager] post:@"Guide" params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                             
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                 
                                     self.guideData = json[@"guide"];
                                     
                                     // Build an array from the dictionary for easy access to each entry
                                     [self updatePhotosArray:self.guideData[@"images"]];
                                     
                                     // Update UI elements
                                     [self updateUIElements];
                                     
                                     // Create the grid of images using the results
                                     [self.photosTable reloadData];
                                     
                                     [self initMapLocations];
                                 }
                                 
                                 else {}
                             }
                                  viewForHUD:self.view];
}


- (void)updateUIElements {
	
	NSString *thumbURLString = [NSString stringWithFormat:@"%@%@", FRONT_END_ADDRESS,[self.guideData objectForKey:@"thumb"]];
	
	// Download and display the guide thumbnail photo
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:thumbURLString]] success:^(UIImage *requestedImage) {
		
		[self.guideThumb setImage:requestedImage];
	}];
	[operation start];
	

	// Guide title
	[self.titleLabel setText:[self.guideData objectForKey:@"title"]];
	
	// Author label
	NSDictionary *userDict = [self.guideData objectForKey:@"author"];
    NSString *authorText = [NSString stringWithFormat:@"by %@", [userDict objectForKey:@"username"]];
    
    // AUTHOR BUTTON
    CGFloat fontSize = 13.0;
    CGFloat leftPadding = 8.0;
    CGFloat btnXPos = self.authorBtn.frame.origin.x;
    UIFont *btnFont = [UIFont fontWithName:@"FreightSansBold" size:fontSize];
    CGSize expectedAuthorSize = [authorText sizeWithFont:btnFont];
    
    CGRect newAuthorFrame = self.authorBtn.frame;
    newAuthorFrame.size.width = expectedAuthorSize.width;
    [self.authorBtn setFrame:newAuthorFrame];
    [self.authorBtn setBackgroundColor:[UIColor clearColor]];
    [self.authorBtn setTitle:authorText forState:UIControlStateNormal];	
    
    CGFloat authorWidth = expectedAuthorSize.width;
    
    
    // Photos button
    NSString *photosCountString;
    NSInteger photosCount = [[self.guideData objectForKey:@"imagecount"] intValue];
    if (photosCount == 1) photosCountString = [NSString stringWithFormat:@"%@ photo", [self.guideData objectForKey:@"imagecount"]];
    else photosCountString = [NSString stringWithFormat:@"%@ photos", [self.guideData objectForKey:@"imagecount"]];
    CGSize expectedPhotosCountSize = [photosCountString sizeWithFont:btnFont];

    
    btnXPos += authorWidth + leftPadding;
    CGRect newPhotosFrame = self.photosCountBtn.frame;
    newPhotosFrame.size.width = 13 + expectedPhotosCountSize.width;
    newPhotosFrame.origin.x = btnXPos;
    [self.photosCountBtn setFrame:newPhotosFrame];
    
    [self.photosCountBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
    [self.photosCountBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
    [self.photosCountBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self.photosCountBtn setBackgroundColor:[UIColor clearColor]];
    [self.photosCountBtn setTitle:photosCountString forState:UIControlStateNormal];
    
    CGFloat photosWidth = 13 + expectedPhotosCountSize.width;
    
    
    // Elapsed time button
    NSString *elapsedTimeString = [self.guideData objectForKey:@"elapsed"];
    CGSize elapsedTimeSize = [elapsedTimeString sizeWithFont:btnFont];
    
    btnXPos += photosWidth + leftPadding;
//    CGRect newTimeFrame = self.timeElapsedBtn.frame;
//    newTimeFrame.size.width = 13 + elapsedTimeSize.width;
//    newTimeFrame.origin.x = btnXPos;
//    [self.timeElapsedBtn setFrame:newTimeFrame];
//    
//    [self.timeElapsedBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 3)];
//    [self.timeElapsedBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 3, 0, 0)];
//    [self.timeElapsedBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    
//    [self.timeElapsedBtn setBackgroundColor:[UIColor clearColor]];
//    [self.timeElapsedBtn setTitle:elapsedTimeString forState:UIControlStateNormal];
    
    self.descriptionView.text = @"There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour";
	
}

- (IBAction)tweetButtonTapped:(id)sender {
        
    NSString *name = [self.guideData objectForKey:@"title"];
    NSString *initialText = [NSString stringWithFormat:@"Via Gyde for iOS: %@", name];
    
    //Check for Social Framework availability (iOS 6)
    if(NSClassFromString(@"SLComposeViewController") != nil){
        
        if([SLComposeViewController instanceMethodForSelector:@selector(isAvailableForServiceType)] != nil)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                NSLog(@"service available");
                SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                [composeViewController setInitialText:initialText];
                [composeViewController addImage:self.guideThumb.image];
                [self presentViewController:composeViewController animated:YES completion:nil];
            }
            else
            {
                NSLog(@"service not available!");
            }
        }
    }
    
    else{
        
        // For TWTweetComposeViewController (iOS 5)
        if ([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetVC = [[TWTweetComposeViewController alloc] init];
            [tweetVC addImage:self.guideThumb.image];
            [tweetVC setInitialText:initialText];
            [self presentModalViewController:tweetVC animated:YES];
        }
        
        else {
        
            NSString *message = @"You have no Twitter accounts setup on your phone. Please add one via your Settings app and try again.";
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No accounts" message:message
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [av show];
        }
    }
}

- (void)authorButtonTapped:(id)sender {
		
	TAProfileVC *profileVC = [[TAProfileVC alloc] initWithNibName:@"TAProfileVC" bundle:nil];
	
	NSDictionary *userDict = [self.guideData objectForKey:@"author"];
	[profileVC setUsername:[userDict objectForKey:@"username"]];
	
	[self.navigationController pushViewController:profileVC animated:YES];
}

- (void)loveButtonTapped:(id)sender {

    if (isLoved) [self initUnloveAPI];
    
    else [self initLoveAPI];
}


- (void)initIsLovedAPI {
    
    NSDictionary *params = @{ @"username" : [self appDelegate].loggedInUsername, @"code" : self.guideID, @"type" : @"guide" };
    
    [[GlooRequestManager sharedManager] post:@"isLoved" params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                             
                                 if ([json[@"loved"] isEqualToString:@"true"]) isLoved = YES;
                                 else isLoved = NO;
                                 
                                 // Loved status
                                 [self updateLovedStatus];
                             }
                                  viewForHUD:nil];
}


/*	This function is called once an isLovedResponse is received from
 the API. It uses the value of the lovesImage iVar to then set 
 the title of loveButton button. The loveButton is then enable for interaction */
- (void)updateLovedStatus {
	
    if (isLoved) {
    
        [self.loveBtn setImage:[UIImage imageNamed:@"guide-love-button-on.png"] forState:UIControlStateNormal];
    }
	
	else {
        
        [self.loveBtn setImage:[UIImage imageNamed:@"guide-love-button.png"] forState:UIControlStateNormal];
    }
}


- (void)initLoveAPI {
		
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@&type=guide", [self appDelegate].loggedInUsername, self.guideID, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"Love";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedLoveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedLoveResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
		
//		[jsonString release];
	}
	
	// The "Love" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isLoved = YES;
		
		[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
//	[loveFetcher release];
	loveFetcher = nil;
    
}


- (void)initUnloveAPI {
		
	// Create API parameters
	NSString *jsonString = [NSString stringWithFormat:@"username=%@&code=%@&token=%@&type=guide", [self appDelegate].loggedInUsername, self.guideID, [self appDelegate].sessionToken];	
	NSData *postData = [NSData dataWithBytes:[jsonString UTF8String] length:[jsonString length]];
	
	// Create the URL that will be used to authenticate this user
	NSString *methodName = @"UnLove";
	NSURL *url = [[self appDelegate] createRequestURLWithMethod:methodName testMode:NO];
	
	// Initialiase the URL Request
	NSMutableURLRequest *request = [[self appDelegate] createPostRequestWithURL:url postData:postData];
	
	loveFetcher = [[HTTPFetcher alloc] initWithURLRequest:request
												 receiver:self action:@selector(receivedUnloveResponse:)];
	[loveFetcher start];
}


// Example fetcher response handling
- (void)receivedUnloveResponse:(HTTPFetcher *)aFetcher {
    
	HTTPFetcher *theJSONFetcher = (HTTPFetcher *)aFetcher;
	
	NSAssert(aFetcher == loveFetcher,  @"In this example, aFetcher is always the same as the fetcher ivar we set above");
	
	BOOL success = NO;
	NSInteger statusCode = [theJSONFetcher statusCode];
	
	if ([theJSONFetcher.data length] > 0 && statusCode == 200) {
		
		// Store incoming data into a string
		NSString *jsonString = [[NSString alloc] initWithData:theJSONFetcher.data encoding:NSUTF8StringEncoding];
		
		// Create a dictionary from the JSON string
		NSDictionary *results = [jsonString objectFromJSONString];
		
		if ([[results objectForKey:@"result"] isEqualToString:@"ok"]) success = YES;
		
		NSLog(@"jsonString:%@", jsonString);
		
//		[jsonString release];
	}
	
	// The "UnLove" request was successfull
	// Now update the iVar and UI
	if (success) {
		
		isLoved = NO;
		
		[self updateLovedStatus];
	}
	
	// This is to update the correct "ImageView" when viewing a bunch
	// of images within a "Timeline" view controller
	//if (success) [self updateImageViewWithImageID:imageID loveStatus:NO];
	
//	[loveFetcher release];
	loveFetcher = nil;
    
}


- (void)initRecommendAPI:(NSMutableArray *)usernames {
	
	NSString *usernamesStr = [NSString stringWithFormat:@"%@", [usernames componentsJoinedByString:@","]];
    NSDictionary *params = @{ @"type" : @"guide", @"token" : [[self appDelegate] sessionToken], @"username" : [self appDelegate].loggedInUsername, @"code" : self.guideID, @"usernames" : usernamesStr };
	
    [[GlooRequestManager sharedManager] post:@"Recommend" params:params
                               dataLoadBlock:^(NSDictionary *json){}
                             completionBlock:^(NSDictionary *json){
                                 
                                 if ([json[@"result"] isEqualToString:@"ok"]) {
                                     
                                     NSLog(@"RECOMMENDED SUCCESSFULLY!");
                                 }
                             }
                                  viewForHUD:self.view];
}


- (IBAction)initFollowersList:(id)sender {
	
	TAUsersVC *usersVC = [[TAUsersVC alloc] initWithNibName:@"TAUsersVC" bundle:nil];
	[usersVC setUsersMode:UsersModeRecommendTo];
	[usersVC setSelectedUsername:[self appDelegate].loggedInUsername];
	[usersVC setDelegate:self];
	
	[self.navigationController pushViewController:usersVC animated:YES];
}


- (void)initMapLocations {
	
	// Map type
	self.guideMap.mapType = MKMapTypeStandard;
	
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.09;
	span.longitudeDelta = 0.09;
	
	for (int i = 0; i < [self.photos count]; i++) {
		
		Photo *photo = [self.photos objectAtIndex:i];
		
		CLLocationCoordinate2D coordLocation;
		coordLocation.latitude = [photo.latitude doubleValue];
		coordLocation.longitude = [photo.longitude doubleValue];
		
		if (i == 0) {
			
			region.span = span;
			region.center = coordLocation;
			
			[self.guideMap setRegion:region animated:TRUE];
			[self.guideMap regionThatFits:region];
		}
		
		NSString *title = photo.venue.title;
		if ([title length] == 0) title = @"[untitled]";
		
		MyMapAnnotation *mapAnnotation = [[MyMapAnnotation alloc] initWithCoordinate:coordLocation title:title];
        [mapAnnotation setLocationID:[photo photoID]];
		[self.guideMap addAnnotation:mapAnnotation];
	}
}


/*
 Iterates through the self.images array,  
 converts all the Dictionary values to
 Photos (NSManagedObjects) and stores
 them in self.photos array
 */
- (void)updatePhotosArray:(NSArray *)imagesArray {
	
	NSManagedObjectContext *context = [self appDelegate].managedObjectContext;
	
	for (NSDictionary *image in imagesArray) {
		
		Photo *photo = [Photo photoWithPhotoData:image inManagedObjectContext:context];
		if (photo) [self.photos addObject:photo];
	}
}


- (void)goToMapDetails:(id)sender {
    
    NSArray *mapAnnotations = [[self.guideMap annotations] copy];

	TAMapVC *mapVC = [[TAMapVC alloc] initWithNibName:@"TAMapVC" bundle:nil];
	[mapVC setMapMode:MapModeMultipleAnnotations];
    
	[mapVC setMapAnnotations:mapAnnotations];
	
	[self.navigationController pushViewController:mapVC animated:YES];
}


- (void)checkFacebookPublishPermissions {
    
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        
        // No permissions found in session, ask for it
        [FBSession.activeSession
         requestNewPublishPermissions:
         [NSArray arrayWithObject:@"publish_actions"]
         defaultAudience:FBSessionDefaultAudienceFriends
         completionHandler:^(FBSession *session, NSError *error) {
             if (!error) {
                 // If permissions granted, publish the story
                 [self postToFeed];
             }
         }];
    } else {
        // If permissions present, publish the story
        [self postToFeed];
    }
}


- (void)postToFeed {

    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:self.postParams
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         if (error) {
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertText = [NSString stringWithFormat:
                          @"Posted action, id: %@",
                          [result objectForKey:@"id"]];
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
     }];
}


- (IBAction)publishGuideToFacebookFeed:(id)sender {

    if (!self.postParams) {
        
        NSString *name = [self.guideData objectForKey:@"title"];
        NSString *message = @"Gyde for iOS.";
        NSString *link = @"http://want.supergloo.net.au";
        NSString *thumbURL = [NSString stringWithFormat:@"http://want.supergloo.net.au%@", [self.guideData objectForKey:@"thumb"]];
        NSString *description = @"There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form.";
        
        self.postParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                           link, @"link",
                           thumbURL, @"picture",
                           name, @"name",
                           message, @"caption",
                           description, @"description",
                           nil];
    }
    
    
    if (!FBSession.activeSession.isOpen) {
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookSessionAvailable) name:@"facebook_session_available" object:nil];
        [[FacebookHelper sharedHelper] openSessionWithAllowLoginUI:YES];
    }
    else [self checkFacebookPublishPermissions];
}


- (void)facebookSessionAvailable {
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"facebook_session_available" object:nil];
	if (FBSession.activeSession.isOpen) {
        
        [self checkFacebookPublishPermissions];
    }
}


- (IBAction)postPhotoClick:(id)sender {
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    
//    if (FBSession.activeSession.isOpen) { //session is open so can post right away
//        
//        // Just use the icon image from the application itself.  A real app would have a more
//        // useful way to get an image.
//        UIImage *img = [self.guideThumb image];
//        
//        // if it is available to us, we will post using the native dialog
//        BOOL displayedNativeDialog = [FBNativeDialogs presentShareDialogModallyFrom:self
//                                                                        initialText:nil image:img url:nil handler:nil];
//        
//        if (!displayedNativeDialog) {
//         
//            [self performPublishAction:^{
//
//            [FBRequestConnection startForUploadPhoto:img
//                                completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                                    [self showAlert:@"Photo Post" result:result error:error];
//                                }];
//            }];
//        }
//    }
//    
//    else //session isn't open so authenticate first, then can post when back to app through notification
//    {
//        NSLog(@"Facebook Active Session not open");
//        // The user has initiated a login, so call the openSession method
//        // and show the login UX if necessary.
//        [appDelegate openSessionWithAllowLoginUI:YES];
//    }
}


// Convenience method to perform some action that requires the "publish_actions" permissions.
- (void) performPublishAction:(void (^)(void)) action {
    
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession reauthorizeWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                                   defaultAudience:FBSessionDefaultAudienceFriends
                                                 completionHandler:^(FBSession *session, NSError *error) {
                                                     if (!error) {
                                                         action();
                                                     }
                                                     //For this example, ignore errors (such as if user cancels).
                                                 }];
    } else {
        action();
    }
    
}


// UIAlertView helper for post buttons
- (void)showAlert:(NSString *)message result:(id)result
            error:(NSError *)error {
    
    NSString *alertMsg;
    NSString *alertTitle;
    if (error) {
        alertMsg = error.localizedDescription;
        alertTitle = @"Error";
    } else {
        NSDictionary *resultDict = (NSDictionary *)result;
        alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.\nPost ID: %@",
                    message, [resultDict valueForKey:@"id"]];
        alertTitle = @"Success";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMsg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


#pragma mark MFMailComposeViewControllerDelegate

// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
    // Notifies users about errors associated with the interface
    switch (result) {
            
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}


- (IBAction)displayEmail:(id)sender {

    // Email message here
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    // SUBJECT
    [picker setSubject:@"RE: Tourism App"];
    
    // TO ADDRESS...
    NSArray *recipients = [[NSArray alloc] initWithObjects:@"hello@c2.net.au", nil];
    [picker setToRecipients:recipients];
    
    // BODY TEXT
    NSString *bodyContent = @"I was using the Tourism App...";
    NSString *emailBody = [NSString stringWithFormat:@"%@\n\n", bodyContent];
    [picker setMessageBody:emailBody isHTML:NO];
    
    // SHOW INTERFACE
    [self presentModalViewController:picker animated:YES];
}

@end
