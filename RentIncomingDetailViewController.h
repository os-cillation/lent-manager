//
//  AddEntryViewController.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "DateSelectViewController.h"

@class RentEntry;


@interface RentOutgoingDetailViewController : UIViewController <UITextFieldDelegate, DateSelectViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate, ABPersonViewControllerDelegate> {
	RentEntry *entry;
	UITextField *activeField;
	IBOutlet UITextField *descriptionTxt;
	IBOutlet UISegmentedControl *type;
	IBOutlet UITextField *personTxt;
	IBOutlet UITextField *dateTxt;
	IBOutlet UIScrollView *scrollView;
	NSString *personId;
	NSDate *date;
}

@property (nonatomic, retain) RentEntry *entry;
@property (nonatomic, retain) IBOutlet UITextField *descriptionTxt;
@property (nonatomic, retain) IBOutlet UISegmentedControl *type;
@property (nonatomic, retain) IBOutlet UITextField *personTxt;
@property (nonatomic, retain) IBOutlet UITextField *dateTxt;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)cancel;
- (IBAction)save;
- (IBAction)showDetails;

@end
