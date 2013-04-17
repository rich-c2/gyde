//
//  TagsCell.h
//  Tourism App
//
//  Created by Richard Lee on 3/10/12.
//
//

#import <UIKit/UIKit.h>

#define TAGS_CELL_IDENTIFIER @"Tags Cell Identifier"

@interface TagsCell : UITableViewCell {

	UILabel *tagLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *tagLabel;

+ (NSString *)reuseIdentifier;

@end
