//
//  AbstractTableViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentList.h"
#import "AbstractDetailViewController.h"

@interface AbstractTableViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, AbstractDetailViewControllerDelegate> {
	IBOutlet UISearchBar *searchBar;
	NSMutableArray *tableData;
	RentList *list;
	RentList *allEntries;
	UIBarButtonItem *editButton;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)add;
- (void)stopEdit;

@end