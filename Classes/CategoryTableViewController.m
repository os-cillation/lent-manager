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

#import "CategoryTableViewController.h"
#import "CategoryAddViewController.h"
#import "Category.h"
#import "Database.h"


@implementation CategoryTableViewController

@synthesize categories = _categories;
@synthesize editButton = _editButton;

#pragma mark -
#pragma mark Constructors and destructors

- (void)dealloc
{
    [_categories release], _categories = nil;
    [_editButton release], _editButton = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark TODO

- (void)handleAdd
{
	CategoryAddViewController *controller = [[CategoryAddViewController alloc] initWithNibName:@"CategoryAddViewController" bundle:nil];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
    [navController release];
    [controller release];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(startEdit)] autorelease];
    self.navigationItem.leftBarButtonItem = self.editButton;
	[self.editButton setEnabled:NO];
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(handleAdd)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.categories = [Database getAllOwnCategories];
	[self.tableView reloadData];
	self.editButton.enabled = ([self.categories count] > 0);
}

- (void)startEdit
{
	[self.tableView setEditing:YES animated:YES];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] 
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self
								   action:@selector(stopEdit)];
    self.navigationItem.leftBarButtonItem = doneButton;
	[doneButton release];
}

- (void)stopEdit
{
	[self.tableView setEditing:NO animated:YES];
    self.navigationItem.leftBarButtonItem = self.editButton;
	self.editButton.enabled = ([self.categories count] > 0);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categories count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    Category *category = [self.categories objectAtIndex:indexPath.row];
    cell.textLabel.text = category.name;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Database deleteCategory:[self.categories objectAtIndex:indexPath.row]];
        self.categories = [Database getAllOwnCategories];
		[self.tableView reloadData];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CategoryDeleted" object:self];
		if([self.categories count] == 0) {
			[self stopEdit];
		}
    }    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryAddViewController *controller = [[CategoryAddViewController alloc] initWithNibName:@"CategoryAddViewController" bundle:nil];
	controller.category = [self.categories objectAtIndex:indexPath.row];
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
    [controller release];
    [navController release];
}



@end

