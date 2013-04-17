//
//  TASimpleTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 15/10/12.
//
//

#import "TASimpleTableCell.h"

@implementation TASimpleTableCell

@synthesize titleLabel;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)SIMPLE_CELL_IDENTIFIER;
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
