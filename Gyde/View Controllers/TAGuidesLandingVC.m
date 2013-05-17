//
//  TAGuidesLandingVC.m
//  Tourism App
//
//  Created by Richard Lee on 25/10/12.
//
//

#import "TAGuidesLandingVC.h"
#import "MyCoreLocation.h"
#import "XMLFetcher.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "City.h"
#import "JSONKit.h"
#import "StringHelper.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"
#import "TAThumbsSlider.h"
#import "TAGuideDetailsVC.h"
#import "Photo.h"
#import "Guide.h"

#define THUMBS_SLIDER_HEIGHT 118.0
#define THUMBS_SLIDER_PADDING 15.0

@interface TAGuidesLandingVC ()

@end

@implementation TAGuidesLandingVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        
		// Observe when the user has actually logged-in
		// so we can then start loading data
		[self initLoginObserver];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
	// Setup nav bar
	[self initNavBar];
    
    self.popularGuides = [NSMutableArray array];
    
	// Get user location
    MyCoreLocation *location = [[MyCoreLocation alloc] init];
    self.locationManager = location;
    
    // We are the delegate for the MyCoreLocation object
    [self.locationManager setCaller:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    
    [self setGuidesScrollView:nil];
    [self setNavBarTitle:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    if (self.locationManager.updating) {
        
        // Start find the user's location
        [self showLoadingWithStatus:@"Updating your location"];
    }
}


#pragma mark - Private Methods
- (void)updateLocationDidFinish:(CLLocation *)loc {
    
    self.currentLocation = loc;
	
	[self.locationManager stopUpdating];
	
	NSLog(@"FOUND LOCATION:%f\%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
	
	[self retrieveLocationData];
}


- (void)updateLocationDidFailWithError:(CLLocation *)loc {
	
	[self hideLoading];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We were unable to locate your current city. Please search for one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}


#pragma ThumsSliderDelegate methods

- (void)thumbTappedWithID:(NSString *)thumbID fromSlider:(TAThumbsSlider *)slider {
    
    
    TAGuideDetailsVC *guideDetailsVC = [[TAGuideDetailsVC alloc] initWithNibName:@"TAGuideDetailsVC" bundle:nil];
    [guideDetailsVC setGuideID:thumbID];

    [self.navigationController pushViewController:guideDetailsVC animated:YES];
}


- (void)initLoginObserver {
	
	// Get an iVar of AppDelegate
	AppDelegate *appDelegate = [self appDelegate];
	
	/*
     Register to receive change notifications for the "userLoggedIn" property of
     the 'appDelegate' and specify that both the old and new values of "userLoggedIn"
     should be provided in the observe… method.
     */
	[appDelegate addObserver:self
				  forKeyPath:@"userLoggedIn"
					 options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
					 context:NULL];
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object change:(NSDictionary *)change
                       context:(void *)context {
	
	NSInteger loggedIn = 0;
	
    if ([keyPath isEqual:@"userLoggedIn"])
		loggedIn = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
	
	
	if (loggedIn == 1) {
		
        [self initLocationManager];
	}
}


#pragma MY METHODS

- (void)willLogout {
    
    [self.navigationController popToRootViewControllerAnimated:NO];
}


- (AppDelegate *)appDelegate {
	
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)initNavBar {
	
	// Hide default nav bar
	self.navigationController.navigationBarHidden = YES;
	
}


- (void)initLocationManager {
    
    [self.navBarTitle setText:@"LOADING"];
    
    // Start find the user's location
    [self showLoadingWithStatus:@"Updating your location"];
    [self.locationManager startUpdating];
}


- (void)retrieveLocationData {
	
	// Create JSON call to retrieve dummy City values
	NSString *methodName = @"geocode";
	NSString *yahooURL = @"http://where.yahooapis.com/";
	NSString *yahooAPIKey = @"UvRWaq30";
	
	NSString *urlString = [NSString stringWithFormat:@"%@%@?q=%f,%f&gflags=R&appid=%@", yahooURL, methodName, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, yahooAPIKey];
	NSLog(@"YAHOO URL:%@", urlString);
	
	NSURL *url = [urlString convertToURL];
	
	// Create the request.
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
														   cachePolicy:NSURLRequestUseProtocolCachePolicy
													   timeoutInterval:45.0];
	[request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPMethod:@"GET"];
	
    if (cityFetcher) {
        
		[cityFetcher cancel];
		cityFetcher = nil;
	}
    
    
	// XML Fetcher
	cityFetcher = [[XMLFetcher alloc] initWithURLRequest:request xPathQuery:@"//ResultSet" receiver:self action:@selector(receivedYahooResponse:)];
	[cityFetcher start];
}


// Example fetcher response handling
- (void)receivedYahooResponse:(XMLFetcher *)aFetcher {
    
    if (![aFetcher isEqual:cityFetcher])
        return;
	
	BOOL requestSuccess = NO;
	BOOL errorDected = NO;
	
	//NSLog(@"PRINTING YAHOO DATA:%@",[[NSString alloc] initWithData:theXMLFetcher.data encoding:NSASCIIStringEncoding]);
	
	// IF STATUS CODE WAS OKAY (200)
	if ([cityFetcher statusCode] == 200) {
		
		// XML Data was returned from the API successfully
		if (([cityFetcher.data length] > 0) && ([cityFetcher.results count] > 0)) {
			
			requestSuccess = YES;
			
			XPathResultNode *versionsNode = [cityFetcher.results lastObject];
			
			// loop through the children of the <registration> node
			for (XPathResultNode *child in versionsNode.childNodes) {
				
				if ([[child name] isEqualToString:@"ErrorMessage"]) {
					
					errorDected = ([[child contentString] isEqualToString:@"No error"] ? NO : YES);
				}
				
				else if ([[child name] isEqualToString:@"Result"]) {
					
					for (XPathResultNode *childNode in child.childNodes) {
						
						if ([[childNode name] isEqualToString:@"city"] && [[childNode contentString] length] > 0) {
							
							self.selectedCity = [City cityWithTitle:[childNode contentString] inManagedObjectContext:self.managedObjectContext];
						}
					}
				}
			}
		}
	}
    
	if (requestSuccess && !errorDected) {
		
        // City has been found - update the nav bar title
        [self.navBarTitle setText:[[self.selectedCity title] uppercaseString]];
        
        [self initPopularGuidesAPI];
	}
	else {
        
        [self hideLoading];
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We were unable to locate your current city. Please search for one." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[av show];
	}
    
    cityFetcher = nil;
	
}


- (void)showLoadingWithStatus:(NSString *)status {
	
	[SVProgressHUD showInView:self.view status:status networkIndicator:YES posY:-1 maskType:SVProgressHUDMaskTypeClear];
}


- (void)hideLoading {
	
	[SVProgressHUD dismissWithSuccess:@"Loaded!"];
}


- (void)initPopularGuidesAPI {
    
    // Convert string to data for transmission
    NSString *popularGuidesString = [NSString stringWithFormat:@"pg=0&sz=%i", 6];
    NSMutableData *popularGuidesData = [NSMutableData dataWithBytes:[popularGuidesString UTF8String] length:[popularGuidesString length]];
	
	// Create the URL that will be used to authenticate this user
	NSURL *popularGuidesURL = [[self appDelegate] createRequestURLWithMethod:@"popularguides" testMode:NO];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:popularGuidesURL];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded"];
    [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [popularGuidesData length]]];
    [request setRequestMethod:@"POST"];
    
    [request setPostBody:popularGuidesData];
    [request setDelegate:self];
    [request setDidFinishSelector:@selector(popularGuidesFinished:)];
    [request setDidFailSelector:@selector(popularGuidesFailed:)];
    
    [request startAsynchronous];
}


- (void)popularGuidesFinished:(ASIHTTPRequest*)req {
    
    [self hideLoading];
    
    //NSLog(@"PHOTOS FINISHED:%@", [req responseString]);
    
    // Create a dictionary from the JSON string
    NSDictionary *results = [[req responseString] objectFromJSONString];
    
    // Build an array from the dictionary for easy access to each entry
    self.popularGuides = [[self appDelegate] serializeGuideData:[results objectForKey:@"guides"]];
    
    [self createGuideSliders];
}

- (void)popularGuidesFailed:(ASIHTTPRequest *)req {

    [self hideLoading];
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"We were unable to fetch the popular guides for this city." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}


- (NSMutableArray *)createSliderDataWithPhotos:(NSSet *)photos forGuide:(Guide *)guide {
    
	NSMutableArray *thumbDictionaries = [NSMutableArray array];
    
    NSArray *photosArray = [photos allObjects];
	
	for (Photo *photo in photosArray) {
		
		NSDictionary *thumbData = [NSDictionary dictionaryWithObject:[photo thumbURL] forKey:[guide guideID]];
		
		[thumbDictionaries addObject:thumbData];
	}
	
	return thumbDictionaries;
}


- (void)createGuideSliders {
	
	CGFloat xPos = 0.0;
	CGFloat yPos = 12.0;
	CGFloat sliderWidth = 320.0;    
    
    for (Guide *guide in self.popularGuides) {
        
        NSString *lovesCount = [NSString stringWithFormat:@"%i", guide.lovesCount.intValue];
    
        CGRect tsFrame = CGRectMake(xPos, yPos, sliderWidth, THUMBS_SLIDER_HEIGHT);
        TAThumbsSlider *slider = [[TAThumbsSlider alloc] initWithFrame:tsFrame title:guide.title username:[guide.author username] lovesCount:lovesCount photosCount:@"26"];
        [slider setSliderMode:SliderModePhotos];
        [slider setDelegate:self];
        [slider.progressBar setHidden:YES];
        
        NSMutableArray *thumbsDictionaries = [self createSliderDataWithPhotos:guide.photos forGuide:guide];
        [slider setImages:thumbsDictionaries];
        
        [self.guidesScrollView addSubview:slider];
        
        yPos += (THUMBS_SLIDER_HEIGHT + THUMBS_SLIDER_PADDING);
    }
    
    
    [self.guidesScrollView setContentSize:CGSizeMake(self.guidesScrollView.frame.size.width, yPos)];
    [self.guidesScrollView setContentInset:UIEdgeInsetsMake(0, 0, 14, 0)];
}


@end
