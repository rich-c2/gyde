//
//  DefaultCityCell.m
//  Tourism App
//
//  Created by Richard Lee on 2/10/12.
//
//

#import "DefaultCityCell.h"

@implementation DefaultCityCell

@synthesize cityLabel;

+ (NSString *)reuseIdentifier {
	
    return (NSString *)DEFAULT_CITY_CELL_IDENTIFIER;
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
