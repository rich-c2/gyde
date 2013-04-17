//
//  MeVC.h
//  Gyde
//
//  Created by Richard Lee on 1/04/13.
//  Copyright (c) 2013 Richard Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridImage.h"

@class HTTPFetcher;
@class ProfileGuidesTableCell;

@interface MeVC : UIViewController {

    // Data
	HTTPFetcher *profileFetcher;
	HTTPFetcher *isFollowingFetcher;
	HTTPFetcher *unfollowFetcher;
	HTTPFetcher *followFetcher;
	HTTPFetcher *lovedPhotosFetcher;
    HTTPFetcher *uploadsFetcher;
	HTTPFetcher *guidesFetcher;
    HTTPFetcher *lovedGuidesFetcher;
	
	NSMutableArray *photos;
    NSMutableArray *lovedPhotos;
	NSMutableArray *guides;
    NSMutableArray *lovedGuides;
	
	NSString *username;
	NSString *avatarURL;
	
	BOOL loading;
	BOOL profileLoaded;
	BOOL loadingIsFollowing;
	BOOL isFollowingLoaded;
	BOOL viewingCurrentUser;
	BOOL uploadsLoaded;
    BOOL lovedPhotosLoaded;
	BOOL guidesLoaded;
    
	IBOutlet UILabel *followersLabel;
	IBOutlet UILabel *followingLabel;
	
	IBOutlet UIImageView *modePointerView;
    IBOutlet UIScrollView *lovedPlacesScrollView;
	IBOutlet UIScrollView *placesScrollView;
	IBOutlet UITableView *lovedGuidesTable;
    IBOutlet UITableView *guidesTable;
	
	NSInteger fetchSize;
	NSInteger imagesPageIndex;
	
	IBOutlet UITextView *bioView;
	IBOutlet UIImageView *avatarView;
	IBOutlet UILabel *usernameLabel;
	IBOutlet UILabel *currentlyInLabel;
	IBOutlet UIButton *photosBtn;
	IBOutlet UIButton *guidesBtn;
	
	IBOutlet UIButton *settingsBtn;
	IBOutlet UIButton *backBtn;
	
	IBOutlet UIButton *followUserBtn;
	IBOutlet UIButton *followingUserBtn;
	
	IBOutlet UIButton *followingBtn;
	IBOutlet UIButton *followersBtn;
	
	
	// MY CONTENT
	IBOutlet UIButton *myContentBtn;
	IBOutlet UIButton *findFriendsBtn;
	IBOutlet UIScrollView *contentScrollView;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) NSMutableArray *photos;
@property (nonatomic, retain) NSMutableArray *guides;
@property (nonatomic, retain) NSMutableArray *lovedPhotos;
@property (nonatomic, retain) NSMutableArray *lovedGuides;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *avatarURL;

@property (nonatomic, retain) IBOutlet UIImageView *modePointerView;
@property (nonatomic, retain) IBOutlet UIScrollView *lovedPlacesScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *placesScrollView;
@property (nonatomic, retain) IBOutlet UITableView *lovedGuidesTable;
@property (nonatomic, retain) IBOutlet UITableView *guidesTable;

@property (nonatomic, retain) IBOutlet UILabel *followersLabel;
@property (nonatomic, retain) IBOutlet UILabel *followingLabel;

@property (nonatomic, retain) IBOutlet UITextView *bioView;
@property (nonatomic, retain) IBOutlet UIImageView *avatarView;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *currentlyInLabel;
@property (nonatomic, retain) IBOutlet UIButton *photosBtn;
@property (nonatomic, retain) IBOutlet UIButton *guidesBtn;

@property (nonatomic, retain) IBOutlet UIButton *settingsBtn;
@property (nonatomic, retain) IBOutlet UIButton *backBtn;

@property (nonatomic, retain) IBOutlet UIButton *followUserBtn;
@property (nonatomic, retain) IBOutlet UIButton *followingUserBtn;

@property (nonatomic, retain) IBOutlet UIButton *followingBtn;
@property (nonatomic, retain) IBOutlet UIButton *followersBtn;

@property (nonatomic, retain) IBOutlet UIButton *myContentBtn;
@property (nonatomic, retain) IBOutlet UIButton *findFriendsBtn;
@property (nonatomic, retain) IBOutlet UIScrollView *contentScrollView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil observeLogin:(BOOL)observe;

- (IBAction)goBack:(id)sender;

- (void)showLoadingWithStatus:(NSString *)status inView:(UIView *)view;
- (void)hideLoading;

- (void)loadUserDetails;
- (IBAction)followingButtonTapped:(id)sender;
- (IBAction)followersButtonTapped:(id)sender;

- (IBAction)followUserButtonTapped:(id)sender;
- (IBAction)followingUserButtonTapped:(id)sender;

- (IBAction)photosButtonTapped:(id)sender;

- (IBAction)myContentButtonTapped:(id)sender;
- (IBAction)findFriendsButtonTapped:(id)sender;

- (IBAction)placesButtonTapped:(id)sender;
- (IBAction)guidesButtonTapped:(id)sender;

- (void)willLogout;

@end
