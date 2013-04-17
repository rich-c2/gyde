//
//  ProfileGuidesTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 4/10/12.
//
//

#import "ProfileGuidesTableCell.h"
#import "StringHelper.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

@implementation ProfileGuidesTableCell

@synthesize titleLabel, descriptionLabel, thumbView, imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)PROFILE_GUIDES_CELL_IDENTIFIER;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
        // Initialization code
    }
	
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
}


- (void)initImage:(NSString *)urlString {
	
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
		
		[self.thumbView setImage:requestedImage];
	}];
	[operation start];
}


- (void)configureCellWithGude:(Guide *)guide {

	self.titleLabel.text = guide.title;
    self.descriptionLabel.text = guide.desc;
	[self initImage:guide.thumbURL];
}


@end
