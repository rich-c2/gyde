//
//  TAThumbsSlider.h
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import <UIKit/UIKit.h>
#import "ThumbImage.h"

@class TAThumbsSlider;

@protocol ThumbsSliderDelegate

- (void)thumbTappedWithID:(NSString *)thumbID fromSlider:(TAThumbsSlider *)slider;

@end


typedef enum {
	SliderModePhotos = 0,
	SliderModeGuides = 1
} SliderMode;


@interface TAThumbsSlider : UIView <ThumbImageDelegate> {

	NSArray *images;
}

@property SliderMode sliderMode;

@property (nonatomic, retain) id <ThumbsSliderDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIProgressView *progressBar;

- (void)setImages:(NSMutableArray *)imagesArray;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title photosCount:(NSString *)photosCount;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title username:(NSString *)username lovesCount:(NSString *)lovesCount photosCount:(NSString *)photosCount;

@end
