//
//  AbstractDetailViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
	LentEntry *entry;
	Category *currentCategory;
	NSString *personId;
	NSDate *date;
	NSDate *returnDate;
	NSDate *pushAlarmDate;
	BOOL keyboardShown;
}

@property (nonatomic, assign) id <AbstractDetailViewControllerDelegate> delegate;
@property (nonatomic, retain) LentEntry *entry;

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
