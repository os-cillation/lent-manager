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

#import "RentOutgoingDetailViewController.h"
#import "Database.h"
#import "DateSelectViewController.h"


@implementation RentOutgoingDetailViewController

@synthesize scrollView, entry, descriptionTxt, type, personTxt, dateTxt;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)save {
	NSString *typeTxt = [type titleForSegmentAtIndex:[type selectedSegmentIndex]];
	NSString *description = descriptionTxt.text;
	if (entry != nil) {
		[Database deleteOutgoingEntry:self.entry.entryId];
	}
	[Database addOutgoingEntry:typeTxt withName:description forPerson:personId withDate:date];

	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)showDetails {
	if (personId != nil) {
		ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
	
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [personId intValue]);

		personViewController.personViewDelegate = self;
		personViewController.displayedPerson = person;

		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
		personViewController.navigationItem.title = @"Kontaktdetails";
		UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self action:@selector(cancelContact:)];
		personViewController.navigationItem.leftBarButtonItem = cancelButton;
	
		[self presentModalViewController:navController animated:YES];
	
		[cancelButton release];
		[personViewController release];
		[navController release];
	}
}

- (void)cancelContact:(id)sender {
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)dateSelectViewControllerDidFinish:(DateSelectViewController *)controller {
	date = [controller.datePicker date];

	NSString *dateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:date];
	self.dateTxt.text = dateString;
	[dateFormat release];
	
	[self dismissModalViewControllerAnimated:YES];
	[self.dateTxt resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.descriptionTxt.delegate = self;
	self.personTxt.delegate = self;
	self.dateTxt.delegate = self;
	
    [super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
	
	if (self.entry != nil) {
		if ([entry.type isEqual:@"Buch"]) {
				[type setSelectedSegmentIndex:0];
		}
		else if ([entry.type isEqual:@"CD"]) {
			[type setSelectedSegmentIndex:1];
		}
		else if ([entry.type isEqual:@"DVD"]) {
			[type setSelectedSegmentIndex:2];
		}
		else if ([entry.type isEqual:@"Andere"]) {
			[type setSelectedSegmentIndex:3];
		}
		self.descriptionTxt.text = entry.name;
		self.personTxt.text = entry.person;
		self.dateTxt.text = [entry getDateString];
		date = entry.date;
		personId = entry.person;
		
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [entry.person intValue]);
		
		NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
		NSString *fullName;
		if (firstName == nil || lastName == nil) {
			if (firstName == nil) {
				fullName = lastName;
			}
			else {
				fullName = firstName;
			}
		}
		else {
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
		}
		self.personTxt.text = fullName;
	}
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.descriptionTxt) {
		return YES;
	}
	if (textField == self.dateTxt) {
		[textField resignFirstResponder];
		DateSelectViewController *controller = [[DateSelectViewController alloc] initWithNibName:@"DateSelectViewController" bundle:nil];
		controller.delegate = self;
		controller.date = date;
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:YES];
		
		[controller release];
	}
	else if (textField == self.personTxt) {
		[textField resignFirstResponder];
		ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
		peoplePicker.peoplePickerDelegate = self;
		
		[self presentModalViewController:peoplePicker animated:YES];
		[peoplePicker release]; 
	}
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardBoundsUserInfoKey] CGRectValue].size;
    CGRect bkgndRect = activeField.superview.frame;
	
    bkgndRect.size.height += kbSize.height;
    [activeField.superview setFrame:bkgndRect];
	if (activeField.frame.origin.y > 120)
		[scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y - 105) animated:NO];
}



// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
	NSLog(@"keyboardWasHidden");
    NSDictionary* info = [aNotification userInfo];
	
    // Get the size of the keyboard.
    NSValue* aValue = [info objectForKey:UIKeyboardBoundsUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
	
    // Reset the height of the scroll view to its original value
    CGRect viewFrame = [scrollView frame];
    viewFrame.size.height += keyboardSize.height;
    scrollView.frame = viewFrame;
}

//people picker delegate protocol

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[self dismissModalViewControllerAnimated:YES];
}

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectionPerson:(ABRecordRef)person {
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	ABRecordID recordId = ABRecordGetRecordID(person);
	
	personId = [[NSString alloc] initWithFormat:@"%i", recordId];
	
	NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
	NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
	NSString *fullName;
	if (firstName == nil || lastName == nil) {
		if (firstName == nil) {
			fullName = lastName;
		}
		else {
			fullName = firstName;
		}
	}
	else {
		fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
	}
	self.personTxt.text = fullName;
	
	[self dismissModalViewControllerAnimated:YES];
	[self.personTxt resignFirstResponder];
	
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	//If touch location is inside the label then...
	if (CGRectContainsPoint(self.personTxt.frame, [[[event allTouches] anyObject] locationInView:self.view]))
	{
		//Open webpage
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.os-cillation.de"]];	
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	NSLog(@"hello");
	return YES;
}





@end
