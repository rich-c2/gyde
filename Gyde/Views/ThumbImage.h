//
//  ThumbImage.h
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import <UIKit/UIKit.h>

@protocol ThumbImageDelegate

- (void)thumbTapped:(NSString *)thumbID;

@end

@interface ThumbImage : UIView

@property (nonatomic, retain) id <ThumbImageDelegate> delegate;
@property (nonatomic, retain) UIButton *imageView;
@property (nonatomic, retain) NSString *thumbID;

- (id)initWithFrame:(CGRect)frame url:(NSString *)_urlString thumbID:(NSString *)tID;

@end
