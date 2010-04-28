//
//  AddEntryViewController.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DateSelectViewController.h"
#import "ReturnDateSelectViewController.h"

@class RentEntry;


@interface RentOutgoingDetailViewController : UIViewController <UITextFieldDelegate, DateSelectViewControllerDelegate, ReturnDateSelectViewControllerDelegate, ABPersonViewControllerDelegate/*, ABPeoplePickerNavigationControllerDelegate*/> {
	RentEntry *entry;
	UITextField *activeField;
	IBOutlet UITextField *descriptionTxt;
	IBOutlet UITextField *description2Txt;
	IBOutlet UISegmentedControl *type;
	IBOutlet UITextField *personTxt;
	IBOutlet UITextField *dateTxt;
	IBOutlet UITextField *returnDateTxt;
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIButton *detailsButton;
	IBOutlet UIBarButtonItem *saveButton;
	IBOutlet UILabel *description1Label;
	IBOutlet UILabel *description2Label;
	IBOutlet UILabel *lentToLabel;
	IBOutlet UILabel *lentFromLabel;
	IBOutlet UILabel *lentUntilLabel;
	IBOutlet UIButton *deleteDateButton;
	IBOutlet UIButton *deleteReturnDateButton;
	IBOutlet UITableView *contactTableView;
	NSString *personId;
	NSDate *date;
	NSDate *returnDate;
	BOOL keyboardShown;	
}

@property (nonatomic, retain) RentEntry *entry;
@property (nonatomic, retain) IBOutlet UITextField *descriptionTxt;
@property (nonatomic, retain) IBOutlet UITextField *description2Txt;
@property (nonatomic, retain) IBOutlet UISegmentedControl *type;
@property (nonatomic, retain) IBOutlet UITextField *personTxt;
@property (nonatomic, retain) IBOutlet UITextField *dateTxt;
@property (nonatomic, retain) IBOutlet UITextField *returnDateTxt;
@property (nonatomic, retain) IBOutlet UIButton *detailsButton;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UILabel *description1Label;
@property (nonatomic, retain) IBOutlet UILabel *description2Label;
@property (nonatomic, retain) IBOutlet UILabel *lentToLabel;
@property (nonatomic, retain) IBOutlet UILabel *lentFromLabel;
@property (nonatomic, retain) IBOutlet UILabel *lentUntilLabel;
@property (nonatomic, retain) IBOutlet UIButton *deleteDateButton;
@property (nonatomic, retain) IBOutlet UIButton *deleteReturnDateButton;
@property (nonatomic, retain) IBOutlet UITableView *contactTableView;

- (IBAction)cancel;
- (IBAction)save;
- (IBAction)showDetails;
- (IBAction)typeChanged;
- (IBAction)clearDate;
- (IBAction)clearReturnDate;
- (void)resignKeyboard;
- (void)updateStrings;

@end
