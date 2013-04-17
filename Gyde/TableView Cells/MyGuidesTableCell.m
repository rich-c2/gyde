//
//  MyGuidesTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 1/10/12.
//
//

#import "MyGuidesTableCell.h"
#import "StringHelper.h"
#import "DictionaryHelper.h"
#import "UIImageView+AFNetworking.h"

@implementation MyGuidesTableCell

@synthesize titleLabel, authorLabel, thumbView, cellSpinner, imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)GUIDE_CELL_IDENTIFIER;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initImageDownload:(NSString *)urlString {
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] success:^(UIImage *requestedImage) {
		
		[self.thumbView setImage:requestedImage];
        [self.cellSpinner stopAnimating];
	}];
    
	[operation start];
}


@end
