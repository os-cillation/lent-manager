//
//  LentIncomingViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "LentIncomingViewController.h"
#import "LentIncomingDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "LentEntry.h"
#import "AboutViewController.h"


@implementation LentIncomingViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	int count = [Database getIncomingCount];
	if (count > 0) {
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", count];
	}
	else {
		self.tabBarItem.badgeValue = nil;
	}
}

- (void)reload
{
	self.allEntries = [Database getIncomingEntries:nil];
	if ([self.searchBar.text length] == 0) {
        self.list.data = self.allEntries.data;
	}
	else {
		self.list = [Database getIncomingEntries:self.searchBar.text];
	}
}

- (void)initializeTableData
{
	self.list = [Database getIncomingEntries:nil];
	if ([self.list sectionCount] > 0) {
		self.editButton.enabled = YES;
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
		self.list = [Database getIncomingEntries:searchBar.text];
	}
    self.editButton.enabled = ([self.list sectionCount] > 0);
	[self.tableView reloadData];
}

- (void)viewDidLoad
{
	self.allEntries = [Database getIncomingEntries:nil];
	[super viewDidLoad];
}

- (void)add
{
	LentIncomingDetailViewController *controller = [[LentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
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
	LentIncomingDetailViewController *controller = [[LentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];
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
		LentEntry *entryAtIndex = [self.list entryForSection:indexPath.section atRow: indexPath.row];
		[Database deleteIncomingEntry:entryAtIndex.entryId];
		[self initializeTableData];
		self.allEntries = [Database getIncomingEntries:nil];
		int count = [Database getIncomingCount];
		if (count > 0) {
			self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", count];
		}
		else {
			self.tabBarItem.badgeValue = nil;
		}
		
		NSMutableDictionary *pushList = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PushAlarmListIncoming"] mutableCopy];
        if (pushList) {
            NSData *data = [pushList objectForKey:entryAtIndex.entryId];
            if (data) {
                UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [pushList removeObjectForKey:entryAtIndex.entryId];
            }
            if ([pushList count]) {
                [[NSUserDefaults standardUserDefaults] setObject:pushList forKey:@"PushAlarmListIncoming"];
            }
            else {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListIncoming"];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            [pushList release];
        }
    }   
}

@end

