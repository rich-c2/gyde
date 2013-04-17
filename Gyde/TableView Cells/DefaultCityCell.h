//
//  DefaultCityCell.h
//  Tourism App
//
//  Created by Richard Lee on 2/10/12.
//
//

#import <UIKit/UIKit.h>

#define DEFAULT_CITY_CELL_IDENTIFIER @"Default City Cell Identifier"

@interface DefaultCityCell : UITableViewCell {

	UILabel *cityLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *cityLabel;

+ (NSString *)reuseIdentifier;

@end
