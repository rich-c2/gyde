//
//  TAUserTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 17/09/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TAUserTableCell.h"
#import "StringHelper.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+RoundedCorner.h"

@implementation TAUserTableCell

@synthesize nameLabel, usernameLabel, thumbView, cellSpinner;
@synthesize followBtn, followingBtn;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)USER_CELL_IDENTIFIER;
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


- (void)setFollowingUser:(BOOL)following {

	if (following) {
     
        self.followingBtn.hidden = NO;
        self.followBtn.hidden = YES;
    }
	else {
        
        self.followingBtn.hidden = YES;
        self.followBtn.hidden = NO;   
    }
}


- (void)initImage:(NSString *)urlString {
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]
                                                                              imageProcessingBlock:nil
                                                                                         cacheName:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                           
                                                                                               [self.cellSpinner stopAnimating];
                                                                                               UIImage *rounded = [image roundedCornerImage:12 borderSize:3];
                                                                                               [self.thumbView setImage:rounded];
                                                                                           }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               
                                                                                               [self.cellSpinner stopAnimating];
                                                                                               UIImage *placeHolder = [UIImage imageNamed:@"avatar_placeholder.png"];
                                                                                               UIImage *rounded = [placeHolder roundedCornerImage:12 borderSize:3];
                                                                                               [self.thumbView setImage:rounded];
                                                                                           }];
	
	[operation start];
}


@end
