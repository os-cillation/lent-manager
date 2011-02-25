//
//  RootViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentIncomingViewController.h"
#import "RentIncomingDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "RentEntry.h"
#import "AboutViewController.h"

@implementation RentIncomingViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	int count = [Database getIncomingCount];
	if (count > 0) {
		self.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}
	else {
		self.tabBarItem.badgeValue = nil;
	}
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
	[super viewDidLoad];
}

- (void)add {
	RentIncomingDetailViewController *controller;
	controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];

	controller.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[searchBar resignFirstResponder];
	RentEntry *entry = [list getSectionData:indexPath.section atRow:indexPath.row];
	RentIncomingDetailViewController *controller = [[RentIncomingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];

	controller.delegate = self;
	controller.entry = entry;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
}

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
		
		NSDictionary *tmpList = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PushAlarmListIncoming"];
		if (!tmpList) {
			return;
		}
		NSMutableDictionary *pushList = [[NSMutableDictionary alloc] initWithDictionary:tmpList];
		
		NSData *data = [pushList objectForKey:entryAtIndex.entryId];
		
		if (data) {
			UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
			notification = nil;
			[pushList removeObjectForKey:entryAtIndex.entryId];
		}
		if ([pushList count] == 0) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListIncoming"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:pushList forKey:@"PushAlarmListIncoming"];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];
    }   
}

@end

