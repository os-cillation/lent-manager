//
//  RootViewController.h
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//
#import "RentList.h"
#import "RentOutgoingDetailViewController.h"

@interface RentOutgoingViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, RentOutgoingDetailViewControllerDelegate> {
	IBOutlet UISearchBar *searchBar;
	NSMutableArray *tableData;
	RentList *list;
	RentList *allEntries;
	UIBarButtonItem *editButton;
	IBOutlet UITableView *myTableView;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;

- (void)add;

@end
