//
//  TAPhotoFrame.h
//  Tourism App
//
//  Created by Richard Lee on 18/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAPullButton.h"
#import "TAPhotoView.h"
#import "TACommentView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>
#import "TAGuideButton.h"
#import "TACreateGuideForm.h"
#import "TAUserButton.h"
#import "TARecommendList.h"

@class HTTPFetcher;
@class TARecommendList;

@protocol PhotoFrameDelegate

- (void)disableScroll;
- (void)enableScroll;
- (void)showCloseButton:(BOOL)show;
- (void)usernameButtonClicked;
- (void)loveButtonTapped:(NSString *)imageID;
- (void)vouchButtonTapped:(NSString *)imageID;
- (void)flagButtonTapped:(NSString *)imageID;
- (void)addPhotoToSelectedGuide:(NSString *)guideID;
- (void)tweetButtonTapped:(NSString *)imageID;
- (void)emailButtonTapped:(NSString *)imageID;
- (void)createGuideWithPhoto:(NSString *)imageID title:(NSString *)title isPrivate:(BOOL)isPrivate;
//- (void)loveCountButtonClicked:(NSString *)imageID;
- (void)commentButtonTapped:(NSString *)imageID commentText:(NSString *)comment;
/*- (void)cityTagButtonClicked:(NSString *)imageID;
- (void)optionsButtonClicked:(NSString *)imageID;
- (void)recommendButtonClicked;

@optional
- (void)mapButtonClicked:(NSString *)imageID;*/

@end

@interface TAPhotoFrame : UIView <UIScrollViewDelegate, PullButtonDelegate, CommentViewDelegate, GuideButtonDelegate, CreateGuideFormDelegate, RecommendListDelegate> {
	
	HTTPFetcher *guidesFetcher;
	HTTPFetcher *followersFetcher;
	HTTPFetcher *recommendFetcher;
	
	NSArray *guides;
	NSString *selectedCity;
	NSString *selectedTag;
	NSNumber *selectedTagID;
	NSNumber *latitude;
	NSNumber *longitude;
	NSArray *followers;
	
	UIView *guidesView;
	TACreateGuideForm *createGuideView;
	
	TARecommendList *recommendListView;
	
	// TEST
	UIView *containerView;
	UIView *container;
	UIScrollView *containerScroll;
	UIScrollView *actionsScrollView;
	UIView *actionsView;
	BOOL pullEnabled;
    
    // Track whether we're viewing
    // main actions list
    BOOL viewingActionsList;
	
	NSString *imageID;
	
	id <PhotoFrameDelegate> delegate;
	
	UIImageView *avatarView;
	TAPhotoView *imageView;
	UIProgressView *progressView;
	NSString *urlString;
}

@property (nonatomic, retain) id <PhotoFrameDelegate> delegate;
@property (nonatomic, retain) NSArray *guides;
@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) NSNumber *selectedTagID;
@property (nonatomic, retain) NSString *selectedTag;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSArray *followers;

@property (nonatomic, retain) UIView *guidesView;
@property (nonatomic, retain) TACreateGuideForm *createGuideView;

@property (nonatomic, retain) TARecommendList *recommendListView;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *container;
@property (nonatomic, retain) UIScrollView *containerScroll;
@property (nonatomic, retain) UIScrollView *actionsScrollView;
@property (nonatomic, retain) UIView *actionsView;

@property (nonatomic, retain) NSString *imageID;

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) TAPhotoView *imageView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *urlString;

- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)_imageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL tag:(NSString *)tagTitle  vouches:(NSInteger)vouches loves:(NSInteger)loves timeElapsed:(NSString *)timeElapsed;


- (void)closeButtonWasTapped;
- (void)initImage;
- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url;


@end
