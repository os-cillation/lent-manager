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
