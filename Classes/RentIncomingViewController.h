//
//  RentIncomingViewController.h
//  RentManager
//
//  Created by Benjamin Mies on 17.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentList.h"
#import "RentIncomingDetailViewController.h"

@interface RentIncomingViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, RentIncomingDetailViewControllerDelegate> {
	IBOutlet UISearchBar *searchBar;
	NSMutableArray *tableData;
	RentList *list;
	RentList *allEntries;
	UIBarButtonItem *editButton;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)add;

@end

