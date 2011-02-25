//
//  CategoryTableViewController.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategoryTableViewController.h"
#import "CategoryAddViewController.h"
#import "Category.h"
#import "Database.h"


@implementation CategoryTableViewController

- (void)handleAdd {
	CategoryAddViewController *controller = [[CategoryAddViewController alloc] initWithNibName:@"CategoryAddViewController" bundle:nil];
	
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
}


#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
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
								  action:@selector(handleAdd)];
    self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	data = [Database getAllOwnCategories];
	[self.tableView reloadData];
	editButton.enabled = ([data count] > 0);
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
	editButton.enabled = ([data count] > 0);
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [[data objectAtIndex:indexPath.row] name];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}




// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [Database deleteCategory:[data objectAtIndex:indexPath.row]];
		data = [Database getAllOwnCategories];
		[self.tableView reloadData];
		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"CategoryDeleted" object:self];
		if([data count] == 0) {
			[self stopEdit];
		}
    }    
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryAddViewController *controller = [[CategoryAddViewController alloc] initWithNibName:@"CategoryAddViewController" bundle:nil];
	controller.category = [data objectAtIndex:indexPath.row];
	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	[self presentModalViewController:navController animated:YES];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)dealloc {
	[data release];
    [super dealloc];
}


@end

