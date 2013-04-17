//
//  TACitiesVC.h
//  Tourism App
//
//  Created by Richard Lee on 25/10/12.
//
//

#import <UIKit/UIKit.h>

@class TagsCell;
@class City;


@protocol CityDelegate

- (void)cityWasSelected:(City *)city;

@end

@interface TACitiesVC : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) id <CityDelegate> delegate;
@property (nonatomic, retain) IBOutlet TagsCell *loadCell;
@property (retain, nonatomic) IBOutlet UITableView *citiesTable;
@property (nonatomic, retain) NSArray *tableData;
@property (retain, nonatomic) IBOutlet UITextField *searchField;


@end
