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

#import "LentOutgoingViewController.h"
#import "LentOutgoingDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "LentEntry.h"
#import "AboutViewController.h"
#import "LentManagerAppDelegate.h"


@implementation LentOutgoingViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	int count = [Database getOutgoingCount];
	if (count > 0) {
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", count];
	}
	else {
		self.tabBarItem.badgeValue = nil;
	}
}

- (void)reload
{
	self.allEntries = [Database getOutgoingEntries:nil];
	if ([self.searchBar.text length] == 0) {
        self.list.data = self.allEntries.data;
	}
	else {
		self.list = [Database getOutgoingEntries:self.searchBar.text];
	}

}

- (void)initializeTableData
{
	self.list = [Database getOutgoingEntries:nil];
	if ([self.list sectionCount] > 0) {
		[self.editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	if ([searchBar.text length] == 0) {
        self.list.data = self.allEntries.data;
	}
	else {
		self.list = [Database getOutgoingEntries:searchBar.text];
	}
    self.editButton.enabled = ([self.list sectionCount] > 0);
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
	self.allEntries = [Database getOutgoingEntries:nil];
	[super viewDidLoad];
}

- (void)add
{
	LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
	controller.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
    [navController release];
	[controller release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.searchBar resignFirstResponder];
	LentEntry *entry = [self.list entryForSection:indexPath.section atRow:indexPath.row];
	LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
	controller.delegate = self;
	controller.entry = entry;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
    [navController release];
	[controller release];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		LentEntry *entryAtIndex = [[self.list entryForSection:indexPath.section atRow:indexPath.row] retain];
		[Database deleteOutgoingEntry:entryAtIndex.entryId];
		[self initializeTableData];
        self.allEntries = [Database getOutgoingEntries:nil];
		[self.tableView reloadData];
		int count = [Database getOutgoingCount];
		if (count > 0) {
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", count];
		}
		else {
			self.tabBarItem.badgeValue = nil;
		}
		NSMutableDictionary *pushList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushAlarmListOutgoing"] mutableCopy];
        if (pushList) {
            NSData *data = [pushList objectForKey:entryAtIndex.entryId];
            if (data) {
                UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [pushList removeObjectForKey:entryAtIndex.entryId];
            }
            if ([pushList count]) {
                [[NSUserDefaults standardUserDefaults] setObject:pushList forKey:@"PushAlarmListOutgoing"];
            }
            else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListOutgoing"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [pushList release];
        }
        [entryAtIndex release];
    }   
}

@end

