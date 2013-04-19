//
//  TAPhotoTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 19/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PHOTO_CELL_IDENTIFIER @"Photo Cell Identifier"
 
@interface TAPhotoTableCell : UITableViewCell {
	
	NSURL *imageURL;
	UILabel *titleLabel;
    UILabel *subtitleLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;

+ (NSString *)reuseIdentifier;
- (void)initImage:(NSString *)urlString;
- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url;

@end
