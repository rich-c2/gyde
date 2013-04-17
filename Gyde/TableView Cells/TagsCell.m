//
//  TagsCell.m
//  Tourism App
//
//  Created by Richard Lee on 3/10/12.
//
//

#import "TagsCell.h"

@implementation TagsCell

@synthesize tagLabel;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)TAGS_CELL_IDENTIFIER;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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


@end
