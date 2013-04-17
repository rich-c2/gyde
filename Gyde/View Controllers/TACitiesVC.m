//
//  TACitiesVC.m
//  Tourism App
//
//  Created by Richard Lee on 25/10/12.
//
//

#import "TACitiesVC.h"
#import "TagsCell.h"
#import "City.h"

@interface TACitiesVC ()

@end

@implementation TACitiesVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Adjust the vertical offset of the table
    [self.citiesTable setContentInset:UIEdgeInsetsMake(-1, 0, 0, 0)];
    
    // Populate our tableData array by
    // fetching all the City objects in
    // the Core Data data store
    [self fetchCities];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    
    [self setCitiesTable:nil];
    [self setSearchField:nil];
    [super viewDidUnload];
    
    self.loadCell = nil;
    self.tableData = nil;
    self.managedObjectContext = nil;
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsIsnTableView:(UITableView *)tableView {
	
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSInteger numberOfRows = [self.tableData count];
    
    return numberOfRows;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TagsCell *cell = (TagsCell *)[tableView dequeueReusableCellWithIdentifier:[TagsCell reuseIdentifier]];
    
    if (cell == nil) {
        
        [[NSBundle mainBundle] loadNibNamed:@"TagsCell" owner:self options:nil];
        cell = _loadCell;
        self.loadCell = nil;
    }
    
    [self configureCell:cell atIndexPath:indexPath tableView:tableView];
    
    return cell;
}


- (void)configureCell:(TagsCell *)cell atIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
	// Retrieve the Tag object from the tableData master array
    City *city = [self.tableData objectAtIndex:[indexPath row]];
	
	// Set the text of the cell
	cell.tagLabel.text = [city title];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    // Need to store the selected City dictionary
    // When the user clicks the 'Set' button this value will be passed
    // back to the delegate
    City *city = [self.tableData objectAtIndex:[indexPath row]];
    [self.delegate cityWasSelected:city];
    
    // Go back to the Explore screen
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma MY METHODS

- (IBAction)goBack:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)fetchCities {
	
	// Create fetch request
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:@"City" inManagedObjectContext:self.managedObjectContext]];
	[fetchRequest setPredicate:nil];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]]];
	
	// Execute the fetch request
	NSError *error = nil;
	self.tableData = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
}


@end
