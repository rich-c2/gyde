//
//  MyGuidesTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 1/10/12.
//
//

#import <UIKit/UIKit.h>

#define GUIDE_CELL_IDENTIFIER @"Guide Cell Identifier"

@interface MyGuidesTableCell : UITableViewCell {
	
	NSURL *imageURL;
	UILabel *titleLabel;
	UILabel *authorLabel;
	UIImageView *thumbView;
	UIActivityIndicatorView *cellSpinner;
}

@property (nonatomic, retain) NSURL *imageURL;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *authorLabel;
@property (nonatomic, retain) IBOutlet UIImageView *thumbView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *cellSpinner;

+ (NSString *)reuseIdentifier;
- (void)initImageDownload:(NSString *)urlString;

@end
