//
//  ProfileGuidesTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import <UIKit/UIKit.h>

#define PROFILE_GUIDES_CELL_IDENTIFIER @"Profile Guides Cell Identifier"

@interface ProfileGuidesTableCell : UITableViewCell {
	
	NSURL *imageURL;
	UILabel *titleLabel;
    UILabel *descriptionLabel;
    
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;
- (void)configureCellWithGude:(Guide *)guide;

@end
