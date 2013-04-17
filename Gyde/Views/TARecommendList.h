//
//  TARecommendList.h
//  Tourism App
//
//  Created by Richard Lee on 8/10/12.
//
//

#import <UIKit/UIKit.h>
#import "TAUserButton.h"

@protocol RecommendListDelegate <NSObject>

- (void)finishedSelectingUsers:(NSMutableArray *)selectedUsers;

@end

@interface TARecommendList : UIView <UserButtonDelegate> {

	id <RecommendListDelegate> delegate;
	
	NSMutableArray *selected;
	NSArray *users;
}

@property (nonatomic, retain) id <RecommendListDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *selected;
@property (nonatomic, retain) UIScrollView *scrollView;

- (void)setUsers:(NSArray *)newUsers;


@end
