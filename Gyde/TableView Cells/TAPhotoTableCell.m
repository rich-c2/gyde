//
//  TAPhotoTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 19/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAPhotoTableCell.h"
#import "ImageManager.h"
#import "StringHelper.h"

@implementation TAPhotoTableCell

@synthesize titleLabel, subtitleLabel, thumbView, cellSpinner, imageURL;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)PHOTO_CELL_IDENTIFIER;
}


- (NSString *)reuseIdentifier {
	
    return [[self class] reuseIdentifier];
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
	
    // Configure the view for the selected state
}


- (void)initImage:(NSString *)urlString {
	
	// TEST CODE
	if (urlString) {
		
		self.imageURL = [urlString convertToURL];
				
		UIImage* img = [ImageManager loadImage:imageURL];
		if (img) {
			
			[self.thumbView setImage:img];
			[self.cellSpinner stopAnimating];
		}
    }
	
	else {
		
		[self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
		[self.cellSpinner stopAnimating];
	}
}


- (void) imageLoaded:(UIImage*)image withURL:(NSURL*)url {
	
	if ([self.imageURL isEqual:url]) {
		
		if (image != nil) {
			
			[self.thumbView setImage:image];
			[self.cellSpinner stopAnimating];
		}
		
		else [self.thumbView setImage:[UIImage imageNamed:@"placeholder-showbags-thumb.jpg"]];
	}
}

@end
