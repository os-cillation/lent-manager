    //
//  AbstractDetailViewController.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AbstractDetailViewController.h"
#import "Database.h"
#import "DateSelectViewController.h"
#import "ContactEntry.h"
#import "Category.h"



@implementation AbstractDetailViewController

@synthesize delegate, entry;

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)changeCategory {
	[self resignKeyboard];
	CategoryPickerViewController *controller = [[CategoryPickerViewController alloc] initWithNibName:@"PickerViewController" bundle:nil];
	controller.delegate = self;
	controller.stringTitle = NSLocalizedString(@"Category", @"");

	controller.data = [Database getAllCategories];
	
	
	
	controller.selectedIndex = 0;
	
	for (int i = 0; i < [controller.data count]; i++) {
		if ([[[controller.data objectAtIndex:i] idx] isEqualToString:currentCategory.idx]) {
			controller.selectedIndex = i;
			break;
		}
	}
	
	[[RentManagerAppDelegate getAppDelegate].window addSubview:controller.view];
}

- (IBAction)showDetails {
	if (personId != nil) {
		PersonViewController *personViewController = [[PersonViewController alloc] init];
		
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [personId intValue]);
		
		personViewController.personViewDelegate = self;
		personViewController.displayedPerson = person;
		personViewController.allowsEditing = NO;
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
		personViewController.navigationItem.title = NSLocalizedString(@"ContactDetails", "");
		
		[self presentModalViewController:navController animated:YES];
		
		[personViewController release];
		[navController release];
	}
}

- (void)changeCategory:(Category *)category {
	currentCategory = category;
	int idx = [[currentCategory idx] intValue];
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""), [Database getDescriptionByIndex:idx]]];
	switch (idx) {
		case 0:
			description1Label.text = NSLocalizedString(@"Author", @"");
			description2Label.text = NSLocalizedString(@"Title", @"");
			break;
		case 1:
			description1Label.text = NSLocalizedString(@"Artist", @"");
			description2Label.text = NSLocalizedString(@"Title", @"");
			break;
		case 2:
			description1Label.text = NSLocalizedString(@"Title", @"");
			description2Label.text = NSLocalizedString(@"AdditionalDescription", @"");
			break;
		case 3:
			description1Label.text = NSLocalizedString(@"Description", @"");
			description2Label.text = NSLocalizedString(@"AdditionalDescription", @"");
			break;
		case 4:
			description1Label.text = NSLocalizedString(@"Amount", @"");
			description2Label.text = NSLocalizedString(@"Description", @"");
			break;
		default:
			description1Label.text = NSLocalizedString(@"Description", @"");
			description2Label.text = NSLocalizedString(@"AdditionalDescription", @"");
			break;
	}
}

- (IBAction)clearDate {
	date = nil;
	dateTxt.text = @"";
}

- (IBAction)clearReturnDate {
	returnDate = nil;
	returnDateTxt.text = @"";
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
	dateTxt.text = dateString;
	[dateFormat release];
	
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];	
}

- (void)returnDateSelectViewControllerDidFinish:(ReturnDateSelectViewController *)controller {
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[controller.datePicker date]];
	returnDate = [[calendar dateFromComponents:components] retain];
	
	if (controller.switchPush.on) {
		pushAlarmDate = [[calendar dateFromComponents:components] retain];
	}
	else {
		entry.pushAlarm = nil;
	}
	
	NSString *dateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:returnDate];
	
	returnDateTxt.text = dateString;
	[dateFormat release];
	
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];
}

- (void)resignKeyboard {
	[dateTxt resignFirstResponder];
	[returnDateTxt resignFirstResponder];
	[descriptionTxt resignFirstResponder];
	[description2Txt resignFirstResponder];
	[personTxt resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"NewEntry", @"");
	
	currentCategory = [[Category alloc] init];
	Category *tmp = [[Database getAllCategories] objectAtIndex:0];
	currentCategory.name = tmp.name;
	currentCategory.idx = tmp.idx;
	
	[self updateStrings];
	
	descriptionTxt.delegate = self;
	description2Txt.delegate = self;
	personTxt.delegate = self;
	dateTxt.delegate = self;
	returnDateTxt.delegate = self;
	
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
	[saveButton setEnabled:NO];
	
	[descriptionTxt addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[description2Txt addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[personTxt addTarget:self action:@selector(contactInfoDidChange) forControlEvents:UIControlEventEditingChanged];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWasHidden:)
												 name:UIKeyboardDidHideNotification object:nil];
	
	if (self.entry != nil) {
		[entry retain];
		self.title = NSLocalizedString(@"Edit", @"");
		
		[self changeCategory:[Database getCategory:entry.type]];
		
		if ([entry.description length] > 0) {
			descriptionTxt.text = entry.description;
			[saveButton setEnabled:YES];
		}
		if ([entry.description2 length] > 0) {
			description2Txt.text = entry.description2;
			[saveButton setEnabled:YES];
		}		
		
		dateTxt.text = [entry getDateString];
		returnDateTxt.text = [entry getReturnDateString];
		
		date = entry.date;
		returnDate = entry.returnDate;
		pushAlarmDate = entry.pushAlarm;
		personTxt.text = entry.personName;
		
		if (entry.person == NULL || entry.person == nil) {
			[detailsButton setHidden:YES];
			return;
		}
		
		ABAddressBookRef ab = ABAddressBookCreate();
		ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, [entry.person intValue]);
		if (person != nil) {
			personId = entry.person;
			[detailsButton setHidden:NO];
		}
		else {
			[detailsButton setHidden:YES];
		}
	}
}

- (void)contactInfoDidChange {
	personId = 0;
	[detailsButton setHidden:YES];
	[contactTableView reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[UIView beginAnimations:nil context:NULL];
	if (textField == personTxt) {
		scrollView.contentSize = CGSizeMake(320, 940);
		[scrollView setContentOffset:CGPointMake(0.0, personTxt.frame.origin.y - 80) animated:NO];
		
		[contactTableView setHidden:NO];
		[contactTableView reloadData];
		
	}
	else {
		
		scrollView.contentSize = CGSizeMake(320, 900);
		[contactTableView setHidden:YES];
		if (textField == dateTxt) {
			[self resignKeyboard];
			DateSelectViewController *controller = [[DateSelectViewController alloc] initWithNibName:@"DateSelectViewController" bundle:nil];
			controller.delegate = self;
			controller.date = date;
			controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentModalViewController:controller animated:YES];
			
			[controller release];
			return NO;
		}
		else if (textField == returnDateTxt) {
			[textField resignFirstResponder];
			ReturnDateSelectViewController *controller = [[ReturnDateSelectViewController alloc] initWithNibName:@"ReturnDateSelectViewController" bundle:nil];
			controller.delegate = self;
			controller.pushAlarm = pushAlarmDate;
			controller.date = returnDate;
			controller.minDate = date;
			controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentModalViewController:controller animated:YES];
			
			[controller release];
			return NO;
		}
	}
	activeField = textField;
	[UIView commitAnimations];
	return YES;
}

- (void)textFieldDidChange {
	if (([descriptionTxt.text length] > 0) || ([description2Txt.text length] > 0)) {
		[saveButton setEnabled:YES];
	}
	else {
		[saveButton setEnabled:NO];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if (textField == personTxt) {
		[contactTableView setHidden:YES];
	}
    [self resignKeyboard];
    return NO;
}

- (void)keyboardWasShown:(NSNotification*)aNotification{
	keyboardShown = YES;
}

- (void)keyboardWasHidden:(NSNotification*)aNotification {
	[UIView beginAnimations:nil context:NULL];
	scrollView.contentSize = CGSizeMake(320, 600);
	keyboardShown = NO;
	[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
	[UIView commitAnimations];
}

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
	/*[entry release];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [Database getContactCount:personTxt.text];
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
    
    // Set up the cell...
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	ContactEntry *contactEntry = [Database getContactInfo:personTxt.text atIndex:indexPath.row];
	personTxt.text = contactEntry.name;
	personId = contactEntry.entryId;
	[detailsButton setHidden:NO];
	[contactTableView setHidden:YES];
	[personTxt resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return NSLocalizedString(@"FromAddressbook", @"");
}

- (IBAction)save {
	@throw([NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (IBAction)save'" userInfo:nil]);
}

- (void)updateStrings {
	@throw([NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (void)updateStrings'" userInfo:nil]);
}
@end
