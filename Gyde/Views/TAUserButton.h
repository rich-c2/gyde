//
//  TAUserButton.h
//  Tourism App
//
//  Created by Richard Lee on 8/10/12.
//
//

#import <UIKit/UIKit.h>

@protocol UserButtonDelegate <NSObject>

- (void)userButtonTapped:(NSString *)username;

@end

@interface TAUserButton : UIView {
	
	id <UserButtonDelegate> delegate;
	
	NSString *username;
	UIImageView *thumbView;
}

@property (nonatomic, retain) id <UserButtonDelegate> delegate;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) UIImageView *thumbView;

- (id)initWithFrame:(CGRect)frame user:(NSString *)buttonUsername name:(NSString *)name thumbURL:(NSString *)urlString;

@end
