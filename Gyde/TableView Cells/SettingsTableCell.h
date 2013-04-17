//
//  SettingsTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 16/10/12.
//
//

#import <UIKit/UIKit.h>

#define SETTINGS_CELL_IDENTIFIER @"Settings Cell Identifier"

@interface SettingsTableCell : UITableViewCell {

    UILabel *titleLabel;
    UIImageView *iconView;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIImageView *iconView;

+ (NSString *)reuseIdentifier;

@end
