//
//  RootViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentOutgoingViewController.h"
#import <AddressBook/AddressBook.h>
#import "RentOutgoingDetailViewController.h"
#import "Database.h"
#import "RentEntry.h"
#import "AboutViewController.h"
#import "RentManagerAppDelegate.h"

@interface RentOutgoingViewController ()

- (void)stopEdit;

@end


@implementation RentOutgoingViewController

@synthesize searchBar, myTableView;

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil) {
		self.myTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (void)initializeTableData {
	NSLog(@"initialize table data...");
	list = [Database getOutgoingEntries:nil];
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	
	[self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)pSearchBar {
	[searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	list = [Database getOutgoingEntries:searchText];
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.delegate = self;
	
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
	self.navigationItem.rightBarButtonItem = nil;
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
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}

- (void)add {
	RentOutgoingDetailViewController *controller = [[RentOutgoingDetailViewController alloc] initWithNibName:@"RentOutgoingDetailViewController" bundle:nil];

	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	list = [Database getOutgoingEntries:searchBar.text];
	
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
		
	if ([entry.description length] == 0 || [entry.description2 length] == 0) {
		if ([entry.description length] == 0 ) {
			cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@", entry.description2];
		}
		else {
			cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@", entry.description];
		}
	}
	else {
		cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@", entry.description, entry.description2];
	}

	cell.detailTextLabel.text = @"";
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [entry.person intValue]);
	
	NSString *fullName = @"";
	
	if (person > 0) {
		NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
		
		
		if (firstName == nil || lastName == nil) {
			if (firstName == nil) {
				fullName = lastName;
			}
			else {
				fullName = firstName;
			}
		}
		else {
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
		}
		fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), fullName];
	}
	else {
		if ([entry.person length] > 0) {
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), entry.person];
		}
	}

	if (entry.date != nil) {
		if ([fullName length] > 0) {
			cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), [entry getDateString], fullName];
		}
		else {
			cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), [entry getDateString]];
		}
	}
	else {
		cell.detailTextLabel.text = fullName;
	}

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
	RentOutgoingDetailViewController *controller = [[RentOutgoingDetailViewController alloc] initWithNibName:@"RentOutgoingDetailViewController" bundle:nil];
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		RentEntry *entryAtIndex = [list getSectionData:indexPath.section atRow: indexPath.row];
		[Database deleteOutgoingEntry:entryAtIndex.entryId];
		[self initializeTableData];
		[self.tableView reloadData];
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

