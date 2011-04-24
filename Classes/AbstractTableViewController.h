//
//  AbstractTableViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "AbstractDetailViewController.h"


@class LentList;

@interface AbstractTableViewController : UITableViewController <UITextFieldDelegate, UISearchBarDelegate, AbstractDetailViewControllerDelegate> {
@private
	LentList *_list;
	LentList *_allEntries;
	UIBarButtonItem *_editButton;
	IBOutlet UISearchBar *_searchBar;
}

@property (nonatomic, retain) LentList *list;
@property (nonatomic, retain) LentList *allEntries;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;

- (void)add;
- (void)stopEdit;

@end
