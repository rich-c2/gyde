//
//  TASimpleTableCell.h
//  Tourism App
//
//  Created by Richard Lee on 15/10/12.
//
//

#import <UIKit/UIKit.h>

#define SIMPLE_CELL_IDENTIFIER @"Simple Cell Identifier"

@interface TASimpleTableCell : UITableViewCell {

    UILabel *titleLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

+ (NSString *)reuseIdentifier;

@end
