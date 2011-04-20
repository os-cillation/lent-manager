//
//  RootViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "LentOutgoingViewController.h"
#import "LentOutgoingDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "LentEntry.h"
#import "AboutViewController.h"
#import "LentManagerAppDelegate.h"

@implementation LentOutgoingViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	int count = [Database getOutgoingCount];
	if (count > 0) {
		self.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}
	else {
		self.tabBarItem.badgeValue = nil;
	}
}


- (void)reload {
	NSLog(@"reload call outgoing");
	allEntries = [Database getOutgoingEntries:nil];
	if ([searchBar.text length] == 0) {
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		[tmp addObjectsFromArray:[allEntries getData]];
		[list setData:tmp];
        [tmp release];
	}
	else {
		list = [Database getOutgoingEntries:searchBar.text];
	}

}

- (void)initializeTableData {
//	NSLog(@"initialize table data...");
	list = [Database getOutgoingEntries:nil];
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else if (self.tableView.editing){
		[self stopEdit];
	}
	
	[self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)pSearchBar textDidChange:(NSString *)searchText {
	if ([searchBar.text length] == 0) {
		NSMutableArray *tmp = [[NSMutableArray alloc] init];
		[tmp addObjectsFromArray:[allEntries getData]];
		[list setData:tmp];
        [tmp release];
	}
	else {
		list = [Database getOutgoingEntries:searchBar.text];
	}
	
	if ([list getSectionCount] > 0) {
		[editButton setEnabled:YES];
	}
	else {
		[editButton setEnabled:NO];
	}
	[self.tableView reloadData];
}

- (void)viewDidLoad {
	allEntries = [Database getOutgoingEntries:nil];
	[super viewDidLoad];
}

- (void)add {
	LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];

	controller.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
    [navController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[searchBar resignFirstResponder];
	LentEntry *entry = [list getSectionData:indexPath.section atRow:indexPath.row];
	LentOutgoingDetailViewController *controller = [[LentOutgoingDetailViewController alloc] initWithNibName:@"AbstractDetailViewController" bundle:nil];

	controller.delegate = self;
	controller.entry = entry;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
	controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:navController animated:YES];
	
	[controller release];
    [navController release];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		LentEntry *entryAtIndex = [list getSectionData:indexPath.section atRow: indexPath.row];
		[Database deleteOutgoingEntry:entryAtIndex.entryId];
		[self initializeTableData];
		allEntries = [Database getOutgoingEntries:nil];
		[self.tableView reloadData];
		int count = [Database getOutgoingCount];
		if (count > 0) {
			self.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
		}
		else {
			self.tabBarItem.badgeValue = nil;
		}
		NSDictionary *tmpList = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushAlarmListOutgoing"];
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
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListOutgoing"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:pushList forKey:@"PushAlarmListOutgoing"];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];
        
        [pushList release];
    }   
}

@end

