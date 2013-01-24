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
