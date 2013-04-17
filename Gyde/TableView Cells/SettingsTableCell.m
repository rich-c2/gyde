//
//  SettingsTableCell.m
//  Tourism App
//
//  Created by Richard Lee on 16/10/12.
//
//

#import "SettingsTableCell.h"

@implementation SettingsTableCell

@synthesize titleLabel, iconView;


+ (NSString *)reuseIdentifier {
	
    return (NSString *)SETTINGS_CELL_IDENTIFIER;
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


@end
