//
//  AbstractTableViewController.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AbstractTableViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "RentEntry.h"
#import "AboutViewController.h"

@implementation AbstractTableViewController

@synthesize searchBar;

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil) {
		// Initialisation code
	}
	return self;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)pSearchBar {
	pSearchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)viewDidLoad {
	NSMutableArray *tmp = [[NSMutableArray alloc] init];
	[tmp addObjectsFromArray:[allEntries getData]];
	list = [[RentList alloc] init];
	[list setData:tmp];
    [super viewDidLoad];
	
	editButton = [[UIBarButtonItem alloc] 
				  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
				  target:self
				  action:@selector(startEdit)];
	
    self.navigationItem.leftBarButtonItem = editButton;
	[editButton setEnabled:NO];
	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(add)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reload)
												 name:@"CategoryDeleted" object:nil];
}

- (void)startEdit {
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(stopEdit)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)stopEdit {
	[self.tableView setEditing:NO animated:YES];
	
    self.navigationItem.leftBarButtonItem = editButton;
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else {
		[editButton setEnabled:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [list getSectionCount];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [list getEntryCount:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.detailTextLabel.numberOfLines = 1;
    }
    RentEntry *entry = [list getSectionData:indexPath.section atRow:indexPath.row];
	if ([entry.firstLine length] == 0) {
		[entry generateIncomingText];
	}
	
	cell.textLabel.text = entry.firstLine;
	
	cell.detailTextLabel.text = entry.secondLine;
	
	cell.detailTextLabel.textColor = [UIColor blackColor];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 
	RentEntry *entry = [list getSectionData:indexPath.section atRow:indexPath.row];
	
    NSDate *currentDate = [[NSDate alloc] init];
	
	NSComparisonResult result = [currentDate compare:entry.returnDate];
	
	if (result == NSOrderedDescending){
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.4 blue:0.4 alpha:1]; 
		return;
	}
	
	cell.backgroundColor = [UIColor whiteColor];
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = [NSString alloc];
	RentEntry *entry = [list getSectionData:section atRow:0];
	title = [[NSString alloc] initWithFormat:@"%@", [Database getDescriptionByIndex:[entry.type intValue]]];
	
    return title;
}

- (void)dealloc {
    [super dealloc];
	[searchBar release];
	[list release];
	[tableData release];
	[editButton release];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
// 	[super scrollViewDidScroll:scrollView];
	[self.searchBar resignFirstResponder];
}

- (void)add {
	
}

- (void)reload {
	
}

@end

