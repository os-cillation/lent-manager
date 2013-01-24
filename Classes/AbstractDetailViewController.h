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

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DateSelectViewController.h"
#import "ReturnDateSelectViewController.h"
#import "PersonViewController.h"
#import "LentEntry.h"
#import "CategoryPickerViewController.h"

@protocol AbstractDetailViewControllerDelegate;

@class Category;

@interface AbstractDetailViewController : UIViewController <UITextFieldDelegate, DateSelectViewControllerDelegate, ReturnDateSelectViewControllerDelegate, ABPersonViewControllerDelegate, PickerViewControllerDelegate> {
	id <AbstractDetailViewControllerDelegate> delegate;
	UITextField *activeField;
	IBOutlet UIButton *buttonType;
	IBOutlet UITextField *descriptionTxt;
	IBOutlet UITextField *description2Txt;
	IBOutlet UITextField *personTxt;
	IBOutlet UITextField *dateTxt;
	IBOutlet UITextField *returnDateTxt;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *description1Label;
	IBOutlet UILabel *description2Label;
	IBOutlet UILabel *lentToLabel;
	IBOutlet UILabel *lentFromLabel;
	IBOutlet UILabel *lentUntilLabel;
	IBOutlet UIButton *detailsButton;
	IBOutlet UIButton *deleteDateButton;
	IBOutlet UIButton *deleteReturnDateButton;
	IBOutlet UITableView *contactTableView;
	BOOL keyboardShown;
@private
	LentEntry *_entry;
	Category *_currentCategory;
	NSString *_personId;
	NSDate *_date;
	NSDate *_returnDate;
	NSDate *_pushAlarmDate;
}

@property (nonatomic, assign) id<AbstractDetailViewControllerDelegate> delegate;
@property (nonatomic, retain) LentEntry *entry;
@property (nonatomic, retain) Category *currentCategory;
@property (nonatomic, copy) NSString *personId;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *returnDate;
@property (nonatomic, retain) NSDate *pushAlarmDate;;

- (IBAction)cancel;
- (IBAction)save;
- (IBAction)changeCategory;
- (IBAction)showDetails;
- (IBAction)clearDate;
- (IBAction)clearReturnDate;
- (void)resignKeyboard;
- (void)updateStrings;
- (void)changeCategory:(Category *)category;

@end

@protocol AbstractDetailViewControllerDelegate
- (void)reload;
@end
