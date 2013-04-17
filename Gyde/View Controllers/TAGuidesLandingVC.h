//
//  TAGuidesLandingVC.h
//  Tourism App
//
//  Created by Richard Lee on 25/10/12.
//
//

#import <UIKit/UIKit.h>
#import "CoreLocation/CoreLocation.h"
#import "TAThumbsSlider.h"

@class Tag;
@class City;
@class MyCoreLocation;
@class ASINetworkQueue;
@class XMLFetcher;


@interface TAGuidesLandingVC : UIViewController <ThumbsSliderDelegate> {

    XMLFetcher *cityFetcher;
}

@property (retain, nonatomic) IBOutlet UIScrollView *guidesScrollView;
@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) MyCoreLocation *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (retain, nonatomic) IBOutlet UILabel *navBarTitle;
@property (nonatomic, retain) NSArray *popularGuides;

@property (nonatomic, retain) Tag *selectedTag;
@property (nonatomic, retain) City *selectedCity;

@property (nonatomic, retain) ASINetworkQueue *queue;
@property (nonatomic, retain) NSMutableArray *requests;

- (void)willLogout;

@end
