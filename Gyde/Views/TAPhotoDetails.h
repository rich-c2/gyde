//
//  TAPhotoDetails.h
//  Tourism App
//
//  Created by Richard Lee on 18/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TAPhotoView.h"
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

@class HTTPFetcher;
@class Photo;

@protocol PhotoDetailsDelegate

- (void)usernameButtonTapped;
- (void)loveButtonTapped:(NSString *)imageID;

- (void)addPhotoToGuide:(NSString *)guideID;
- (void)flagButtonTapped:(NSString *)imageID;

- (void)tweetButtonTapped:(NSString *)imageID;
- (void)facebookButtonTapped:(NSString *)imageID;
- (void)recommendButtonTapped;
 
@optional
- (void)mapButtonTapped:(NSString *)imageID;
- (void)cityTagButtonClicked:(NSString *)imageID;
- (void)tagButtonTapped:(NSNumber *)tagID;
- (void)loveCountButtonTapped:(NSString *)imageID;

@end



@interface TAPhotoDetails : UIView {

    BOOL viewingBack;
}

@property (nonatomic, assign) BOOL isLoved;

@property (nonatomic, retain) id <PhotoDetailsDelegate> delegate;
@property (nonatomic, retain) NSString *selectedCity;
@property (nonatomic, retain) NSNumber *selectedTagID;
@property (nonatomic, retain) NSString *selectedTag;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) UIView *photoView;
@property (nonatomic, retain) UIView *actionsView;

@property (nonatomic, retain) NSString *imageID;

@property (nonatomic, retain) UIImageView *avatarView;
@property (nonatomic, retain) TAPhotoView *imageView;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *urlString;

@property (nonatomic, retain) UIButton *loveBtn;
@property (nonatomic, retain) UIButton *flipBtn;


- (id)initWithFrame:(CGRect)frame imageURL:(NSString *)imageURLString imageID:(NSString *)_imageID isLoved:(BOOL)loved isVouched:(BOOL)vouched caption:(NSString *)caption username:(NSString *)username avatarURL:(NSString *)avatarURL tag:(NSString *)tagTitle  vouches:(NSInteger)vouches loves:(NSInteger)loves timeElapsed:(NSString *)timeElapsed;
- (id)initWithFrame:(CGRect)frame forPhoto:(Photo *)photo loved:(BOOL)loved;


- (void)initImage;
- (void)imageLoaded:(UIImage*)image withURL:(NSURL*)_url;
- (void)updateLoveButton:(BOOL)loved;

@end
