//
//  AddEntryViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentOutgoingDetailViewController.h"
#import "Database.h"
#import "ContactEntry.h"



@implementation RentOutgoingDetailViewController

@synthesize scrollView, entry, descriptionTxt, type, personTxt, dateTxt, returnDateTxt, detailsButton, saveButton,
			description2Txt, description1Label, description2Label, lentToLabel, lentFromLabel, lentUntilLabel,
			deleteDateButton, deleteReturnDateButton, contactTableView;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}
- (IBAction)save {
	//if ([descriptionTxt.text length] > 0) {
		NSString *typeTxt = [NSString stringWithFormat:@"%i",[type selectedSegmentIndex]];
		NSString *description = descriptionTxt.text;
		NSString *description2 = description2Txt.text;
		NSString *personString = personTxt.text;
	
		if (personId > 0) {
			personString = personId;
		}
	
		if (entry != nil) {
			[Database deleteOutgoingEntry:self.entry.entryId];
		}

	[Database addOutgoingEntry:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:date withReturnDate:returnDate];
	//}
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)showDetails {
	if (personId != nil) {
		ABPersonViewController *personViewController = [[ABPersonViewController alloc] init];
	
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [personId intValue]);

		personViewController.personViewDelegate = self;
		personViewController.displayedPerson = person;
		personViewController.allowsEditing = YES;

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

- (IBAction)typeChanged {
	int index = [self.type selectedSegmentIndex];
	switch (index) {
		case 0:
			self.description1Label.text = NSLocalizedString(@"Author", @"");
			self.description2Label.text = NSLocalizedString(@"Title", @"");
			break;
		case 1:
			self.description1Label.text = NSLocalizedString(@"Artist", @"");
			self.description2Label.text = NSLocalizedString(@"Title", @"");
			break;
		case 2:
			self.description1Label.text = NSLocalizedString(@"Title", @"");
			self.description2Label.text = NSLocalizedString(@"AdditionalDescription", @"");
			break;
		case 3:
			self.description1Label.text = NSLocalizedString(@"Description", @"");
			self.description2Label.text = NSLocalizedString(@"AdditionalDescription", @"");
			break;
		default:
			break;
	}
}

- (IBAction)clearDate {
	date = nil;
	self.dateTxt.text = @"";
}
- (IBAction)clearReturnDate {
	returnDate = nil;
	self.returnDateTxt.text = @"";
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
	[self resignKeyboard];
}

- (void)returnDateSelectViewControllerDidFinish:(ReturnDateSelectViewController *)controller {
	returnDate = [controller.datePicker date];
	
	NSString *dateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:returnDate];
	
	self.returnDateTxt.text = dateString;
	[dateFormat release];
	
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];
}

- (void)resignKeyboard {
	[self.dateTxt resignFirstResponder];
	[self.returnDateTxt resignFirstResponder];
	[self.descriptionTxt resignFirstResponder];
	[self.description2Txt resignFirstResponder];
	[self.personTxt resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.scrollView.contentSize = CGSizeMake(320, 1000);
	self.title = NSLocalizedString(@"NewEntry", @"");
	
	[self updateStrings];
	
	self.descriptionTxt.delegate = self;
	self.description2Txt.delegate = self;
	self.personTxt.delegate = self;
	self.dateTxt.delegate = self;
	self.returnDateTxt.delegate = self;
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
								  target:self
								  action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	saveButton = [[UIBarButtonItem alloc] 
									initWithTitle:NSLocalizedString(@"Save", @"")
								    style:UIBarButtonItemStylePlain
									target:self
									action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[self.saveButton setEnabled:NO];
	
	[self.descriptionTxt addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[self.description2Txt addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[self.personTxt addTarget:self action:@selector(contactInfoDidChange) forControlEvents:UIControlEventEditingChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
	
	if (self.entry != nil) {
		self.title = NSLocalizedString(@"Edit", @"");
		[type setSelectedSegmentIndex:[entry.type intValue]];
		[self typeChanged];

		if ([entry.description length] > 0) {
			self.descriptionTxt.text = entry.description;
			[self.saveButton setEnabled:YES];
		}
		if ([entry.description2 length] > 0) {
			self.description2Txt.text = entry.description2;
			[self.saveButton setEnabled:YES];
		}
	
		self.dateTxt.text = [entry getDateString];
		self.returnDateTxt.text = [entry getReturnDateString];
		
		date = entry.date;
		returnDate = entry.returnDate;
		
		if (entry.person == NULL || entry.person == nil) {
			[detailsButton setHidden:YES];
			return;
		}
		
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [entry.person intValue]);
		if (person != nil) {
			personId = entry.person;
		
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
			[detailsButton setHidden:NO];
		}
		else {
			self.personTxt.text = entry.person;
			[detailsButton setHidden:YES];
		}
	}
}

- (void)contactInfoDidChange {
	personId = 0;
	[self.detailsButton setHidden:YES];
//	data = [Database getContactInfo:personTxt.text];
	[self.contactTableView reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	if (textField == self.dateTxt) {
		[self resignKeyboard];
		DateSelectViewController *controller = [[DateSelectViewController alloc] initWithNibName:@"DateSelectViewController" bundle:nil];
		controller.delegate = self;
		controller.date = date;
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:YES];
		
		[controller release];
		return NO;
	}
	else if (textField == self.returnDateTxt) {
		[textField resignFirstResponder];
		ReturnDateSelectViewController *controller = [[ReturnDateSelectViewController alloc] initWithNibName:@"ReturnDateSelectViewController" bundle:nil];
		controller.delegate = self;
		controller.date = returnDate;
		controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
		[self presentModalViewController:controller animated:YES];
		
		[controller release];
		return NO;
	}
	else if (textField == self.personTxt) {
		self.scrollView.contentSize = CGSizeMake(320, 600);
		[self.contactTableView setHidden:NO];
//		data = [Database getContactInfo:personTxt.text];
		[self.contactTableView reloadData];

	}
	activeField = textField;
	return YES;
}

- (void)textFieldDidChange {
	if (([self.descriptionTxt.text length] > 0) || ([self.description2Txt.text length] > 0)) {
		[self.saveButton setEnabled:YES];
	}
	else {
		[self.saveButton setEnabled:NO];
	}
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.personTxt) {
				[self.contactTableView setHidden:YES];
	}
    [self resignKeyboard];
    return NO;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
	[scrollView setContentOffset:CGPointMake(0.0, activeField.frame.origin.y - 50) animated:NO];
	keyboardShown = YES; 
}


// Called when the UIKeyboardDidHideNotification is sent
- (void)keyboardWasHidden:(NSNotification*)aNotification {
	[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:YES];
	self.scrollView.contentSize = CGSizeMake(320, 1000);
	
    keyboardShown = NO;
}

/*
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
	[detailsButton setHidden:NO];
	
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];
	
	return NO;
}

// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
	return NO;
}
*/
 
- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue {
	return YES;
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
/*	[entry release];
	[activeField release];
	[descriptionTxt release];
	[description2Txt release];
	[type release];
	[personTxt release];
	[dateTxt release];
	[returnDateTxt release];
	[scrollView release];
	[saveButton release];
	[description1Label release];
	[description2Label release];
	[lentToLabel release];
	[lentFromLabel release];
	[lentUntilLabel release];
	[detailsButton release];
	[deleteDateButton release];
	[deleteReturnDateButton release];
	[contactTableView release];
	[personId release];
	[date release];
	[returnDate release];*/
}

- (void)updateStrings {
	self.description1Label.text = NSLocalizedString(@"Author", @"");
	self.description2Label.text = NSLocalizedString(@"Title", @"");
	self.lentToLabel.text = NSLocalizedString(@"LentToPerson", @"");
	self.lentFromLabel.text = NSLocalizedString(@"LentToAt", @"");
	self.lentUntilLabel.text = NSLocalizedString(@"LentToUntil", @"");
	self.deleteDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	self.deleteReturnDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	
	[self.type setTitle:[Database getDescriptionByIndex:0] forSegmentAtIndex:0];
	[self.type setTitle:[Database getDescriptionByIndex:1] forSegmentAtIndex:1];
	[self.type setTitle:[Database getDescriptionByIndex:2] forSegmentAtIndex:2];
	[self.type setTitle:[Database getDescriptionByIndex:3] forSegmentAtIndex:3];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [Database getContactCount:self.personTxt.text];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	ContactEntry *contactEntry = [Database getContactInfo:personTxt.text atIndex:indexPath.row];
	
	cell.textLabel.text = contactEntry.name;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ContactEntry *contactEntry = [Database getContactInfo:personTxt.text atIndex:indexPath.row];
	self.personTxt.text = contactEntry.name;
	personId = contactEntry.entryId;
	[self.detailsButton setHidden:NO];
	[self.contactTableView setHidden:YES];
	[self.personTxt resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"FromAddressbook", @"");
}

@end
