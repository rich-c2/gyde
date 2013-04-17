//
//  TAImageDetailsVC.h
//  Tourism App
//
//  Created by Richard Lee on 27/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TAUsersVC.h"

@class HTTPFetcher;

@interface TAImageDetailsVC : UIViewController <UIActionSheetDelegate, RecommendsDelegate> {
	
	// Data
	NSString *imageCode;
	HTTPFetcher *mediaFetcher;
	HTTPFetcher *isLovedFetcher;
	HTTPFetcher *loveFetcher;
	HTTPFetcher *vouchFetcher;
	HTTPFetcher *isVouchedFetcher;
	HTTPFetcher *recommendFetcher;
	
	NSDictionary *imageData;
	NSURL *avatarURL;
	NSURL *selectedURL;
	
	
	// TEMP VERIFIED VIEW
	IBOutlet UIView *verifiedView;
	
	// TEMP LOVES COUNT iVAR
	NSInteger lovesCount;
	
	
	// Loading iVars
	BOOL imageLoaded;
	BOOL loading;
	
	// Loved/Vouched
	BOOL isLoved;
	BOOL isVouched;

	IBOutlet UIScrollView *scrollView;
	
	IBOutlet UIProgressView *progressIndicator;

	IBOutlet UIImageView *avatar;
	IBOutlet UIButton *usernameBtn;
	IBOutlet UIButton *subtitle;
	
	IBOutlet UIImageView *mainPhoto;
	IBOutlet UILabel *captionLabel;
	
	IBOutlet UIButton *loveBtn;
	IBOutlet UIButton *mapBtn;
	IBOutlet UIButton *commentBtn;
	IBOutlet UIButton *lovesCountBtn;
	IBOutlet UIButton *usernameByline;
	
}

@property (nonatomic, retain) NSString *imageCode;
@property (nonatomic, retain) NSDictionary *imageData;
@property (nonatomic, retain) NSURL *avatarURL;
@property (nonatomic, retain) NSURL *selectedURL;

@property (nonatomic, retain) IBOutlet UIView *verifiedView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UIProgressView *progressIndicator;

@property (nonatomic, retain) IBOutlet UIImageView *avatar;
@property (nonatomic, retain) IBOutlet UIButton *usernameBtn;
@property (nonatomic, retain) IBOutlet UIButton *subtitle;

@property (nonatomic, retain) IBOutlet UIImageView *mainPhoto;
@property (nonatomic, retain) IBOutlet UILabel *captionLabel;

@property (nonatomic, retain) IBOutlet UIButton *loveBtn;
@property (nonatomic, retain) IBOutlet UIButton *mapBtn;
@property (nonatomic, retain) IBOutlet UIButton *commentBtn;
@property (nonatomic, retain) IBOutlet UIButton *lovesCountBtn;
@property (nonatomic, retain) IBOutlet UIButton *usernameByline;

- (IBAction)lovesCountButtonTapped:(id)sender;
- (IBAction)loveButtonTapped:(id)sender;
- (IBAction)mapButtonTapped:(id)sender;
- (IBAction)optionsButtonTapped:(id)sender;
- (IBAction)usernameButtonTapped:(id)sender;
- (IBAction)viewComments:(id)sender;
- (IBAction)initFollowersList:(id)sender;

@end
