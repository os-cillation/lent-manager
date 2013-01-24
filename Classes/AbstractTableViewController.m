/*-
 * Copyright 2011 os-cillation GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "AbstractTableViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "LentEntry.h"
#import "AboutViewController.h"


@implementation AbstractTableViewController

@synthesize list = _list;
@synthesize allEntries = _allEntries;
@synthesize editButton = _editButton;
@synthesize searchBar = _searchBar;

- (id)init
{
	self = [super initWithStyle:UITableViewStyleGrouped];
	if (self != nil) {
		// Initialisation code
	}
	return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_list release], _list = nil;
    [_allEntries release], _allEntries = nil;
    [_editButton release], _editButton = nil;
    [_searchBar release], _searchBar = nil;
    [super dealloc];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];
}

- (void)viewDidLoad
{
    self.list = [LentList lentListWithData:self.allEntries.data];
    [super viewDidLoad];
	
	self.editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEdit)] autorelease];
    self.navigationItem.leftBarButtonItem = self.editButton;
	[self.editButton setEnabled:NO];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:@"CategoryDeleted" object:nil];
}

- (void)startEdit
{
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(stopEdit)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)stopEdit
{
	[self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.editButton.enabled = ([self.list sectionCount] > 0);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if ([self.list sectionCount] > 0) {
		self.editButton.enabled = YES;
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	[self.tableView reloadData];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.list sectionCount];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.list entryCountForSection:section];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    LentEntry *entry = [self.list entryForSection:indexPath.section atRow:indexPath.row];
	if ([entry.firstLine length] == 0) {
		[entry generateIncomingText];
	}
	cell.textLabel.text = entry.firstLine;
	cell.detailTextLabel.text = entry.secondLine;
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	LentEntry *entry = [self.list entryForSection:indexPath.section atRow:indexPath.row];
    NSDate *currentDate = [NSDate date];
	if ([currentDate compare:entry.returnDate] == NSOrderedDescending) {
        cell.backgroundColor = [UIColor colorWithRed:1 green:0.4 blue:0.4 alpha:1]; 
	}
    else {
        cell.backgroundColor = [UIColor whiteColor];
    }
} 

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	LentEntry *entry = [self.list entryForSection:section atRow:0];
	return [NSString stringWithFormat:@"%@", [Database getDescriptionByIndex:[entry.type intValue]]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self.searchBar resignFirstResponder];
}

- (void)add
{
	@throw [NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (void)add'" userInfo:nil];
}

- (void)reload
{
	@throw [NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (void)reload'" userInfo:nil];
}

@end

