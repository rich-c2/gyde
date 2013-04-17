//
//  TAUserTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define USER_CELL_IDENTIFIER @"User Cell Identifier"

@interface TAUserTableCell : UITableViewCell {
	
	UILabel *usernameLabel;
	UILabel *nameLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
	
	IBOutlet UIButton *followBtn;
	IBOutlet UIButton *followingBtn;
}

@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;

@property (nonatomic, retain) IBOutlet UIButton *followBtn;
@property (nonatomic, retain) IBOutlet UIButton *followingBtn;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;
- (void)setFollowingUser:(BOOL)following;

@end
