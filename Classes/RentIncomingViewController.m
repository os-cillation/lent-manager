//
//  RootViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentIncomingViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "RentEntry.h"
#import "AboutViewController.h"

@interface RentIncomingViewController ()

- (void)stopEdit;

@end

@implementation RentIncomingViewController

@synthesize searchBar;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil) {
		// Initialisation code
	}
	return self;
}

- (void)reload {

	NSLog(@"reload call incoming");
	allEntries = [Database getIncomingEntries:nil];
	if ([searchBar.text length] == 0) {
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		[tmp addObjectsFromArray:[allEntries getData]];
		[list setData:tmp];
	}
	else {
		list = [Database getIncomingEntries:searchBar.text];
	}
}

- (void)initializeTableData {
	NSLog(@"initialize table data...");
	list = [Database getIncomingEntries:nil];
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}

	
	[self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)pSearchBar {
	pSearchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)pSearchBar textDidChange:(NSString *)searchText {
	if ([pSearchBar.text length] == 0) {
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		[tmp addObjectsFromArray:[allEntries getData]];
		[list setData:tmp];
	}
	else {
		list = [Database getIncomingEntries:pSearchBar.text];
	}
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	allEntries = [Database getIncomingEntries:nil];
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
	
}

- (void)startEdit {
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(stopEdit)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
	//self.navigationItem.rightBarButtonItem = nil;
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
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(add)];
    //self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}

- (void)add {
	RentIncomingDetailViewController *controller;
/*	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iPhone 3.2 or later.
		controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"RentIncomingDetailViewController-iPad" bundle:nil];
	}
	else {*/
		// The device is an iPhone or iPod touch.
		controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"RentIncomingDetailViewController" bundle:nil];
//	}

	controller.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	int count = [Database getIncomingCount];
	if (count > 0) {
		self.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}
	else {
		self.tabBarItem.badgeValue = nil;
	}
	
	
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[searchBar resignFirstResponder];
	RentEntry *entry = [list getSectionData:indexPath.section atRow:indexPath.row];
	RentIncomingDetailViewController *controller;
/*	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// The device is an iPad running iPhone 3.2 or later.
		controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"RentIncomingDetailViewController-iPad" bundle:nil];
	}
	else {*/
		// The device is an iPhone or iPod touch.
		controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"RentIncomingDetailViewController" bundle:nil];
//	}

	controller.delegate = self;
	controller.entry = entry;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *title = [NSString alloc];
	RentEntry *entry = [list getSectionData:section atRow:0];
	title = [[NSString alloc] initWithFormat:@"%@", [Database getDescriptionByIndex:[entry.type intValue]]];
	
    return title;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *title = [NSString alloc];
	int count = [list getEntryCount:section];
	if (count > 1) {
		title = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Entries", @"")];
	}
	else {
		title = [[NSString alloc] initWithFormat:@"%i %@", count, NSLocalizedString(@"Entry", @"")];
	}
    return title;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		RentEntry *entryAtIndex = [list getSectionData:indexPath.section atRow: indexPath.row];
		[Database deleteIncomingEntry:entryAtIndex.entryId];
		[self initializeTableData];
		allEntries = [Database getIncomingEntries:nil];
		int count = [Database getIncomingCount];
		if (count > 0) {
			self.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
		}
		else {
			self.tabBarItem.badgeValue = nil;
		}
    }   
}

- (void)dealloc {
    [super dealloc];
	[searchBar release];
	[list release];
	[tableData release];
	[editButton release];
}


@end

