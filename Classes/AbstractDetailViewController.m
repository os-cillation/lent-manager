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
#import "NSDateFormatter+DateFormatter.h"


@implementation AbstractDetailViewController

@synthesize delegate;
@synthesize entry = _entry;
@synthesize currentCategory = _currentCategory;
@synthesize personId = _personId;
@synthesize date = _date;
@synthesize returnDate = _returnDate;
@synthesize pushAlarmDate = _pushAlarmDate;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_entry release], _entry = nil;
    [_currentCategory release], _currentCategory = nil;
    [_personId release], _personId = nil;
    [_date release], _date = nil;
    [_returnDate release], _returnDate = nil;
    [_pushAlarmDate release], _pushAlarmDate = nil;
	[super dealloc];
}

- (IBAction)cancel
{
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)changeCategory
{
	[self resignKeyboard];
	CategoryPickerViewController *controller = [[CategoryPickerViewController alloc] initWithNibName:@"PickerViewController" bundle:nil];
	controller.delegate = self;
	controller.stringTitle = NSLocalizedString(@"Category", @"");
	controller.data = [Database getAllCategories];
	controller.selectedIndex = 0;
	for (int i = 0; i < [controller.data count]; i++) {
		if ([[[controller.data objectAtIndex:i] index] isEqualToString:self.currentCategory.index]) {
			controller.selectedIndex = i;
			break;
		}
	}
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];    
    [self presentModalViewController:navigationController animated:YES];
    [navigationController release];
    [controller release];
     
    
    /*
    [[self navigationController] presentModalViewController:controller animated:YES];
    [controller release];
     */
	
	// [[LentManagerAppDelegate getAppDelegate].window addSubview:controller.view];
}

- (IBAction)showDetails
{
	if (self.personId) {
		PersonViewController *personViewController = [[PersonViewController alloc] init];
		personViewController.personViewDelegate = self;
		personViewController.displayedPerson = ABAddressBookGetPersonWithRecordID(personViewController.addressBook, [self.personId intValue]);
		personViewController.allowsEditing = NO;
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:personViewController];
		personViewController.navigationItem.title = NSLocalizedString(@"ContactDetails", "");
		[self presentModalViewController:navController animated:YES];
		[personViewController release];
		[navController release];
	}
}

- (void)changeCategory:(Category *)category
{
    self.currentCategory = category;
	int index = [category.index intValue];
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""), [Database getDescriptionByIndex:index]]];
	switch (index) {
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
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)clearDate
{
	self.date = nil;
	dateTxt.text = @"";
}

- (IBAction)clearReturnDate
{
	self.returnDate = nil;
	returnDateTxt.text = @"";
	self.pushAlarmDate = nil;
}

- (void)cancelContact:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)dateSelectViewControllerDidFinish:(DateSelectViewController *)controller
{
	self.date = [controller.datePicker date];
    dateTxt.text = [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:self.date];
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];	
}

- (void)returnDateSelectViewControllerDidFinish:(ReturnDateSelectViewController *)controller
{
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit fromDate:[controller.datePicker date]];
    self.returnDate = [calendar dateFromComponents:components];
	if (controller.switchPush.on) {
        self.pushAlarmDate = self.returnDate;
	}
	else {
		self.pushAlarmDate = nil;
	}
    [calendar release];
    returnDateTxt.text = [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:self.returnDate];
	[self dismissModalViewControllerAnimated:YES];
	[self resignKeyboard];
}

- (void)resignKeyboard
{
	[dateTxt resignFirstResponder];
	[returnDateTxt resignFirstResponder];
	[descriptionTxt resignFirstResponder];
	[description2Txt resignFirstResponder];
	[personTxt resignFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.title = NSLocalizedString(@"NewEntry", @"");

	self.currentCategory = [[Database getAllCategories] objectAtIndex:0];
	[self updateStrings];
	[self changeCategory:self.currentCategory];
	
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
	
    [saveButton release];
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
	
	if (self.entry) {
		self.title = NSLocalizedString(@"Edit", @"");
		
		[self changeCategory:[Database getCategory:self.entry.type]];
		
		if ([self.entry.description length]) {
			descriptionTxt.text = self.entry.description;
			saveButton.enabled = YES;
		}
		if ([self.entry.description2 length]) {
			description2Txt.text = self.entry.description2;
			saveButton.enabled = YES;
		}		
		
		dateTxt.text = self.entry.dateString;
		returnDateTxt.text = self.entry.returnDateString;
        self.date = self.entry.date;
		self.returnDate = self.entry.returnDate;
		self.pushAlarmDate = self.entry.pushAlarm;
		personTxt.text = self.entry.personName;
		
		if (!self.entry.person) {
			detailsButton.hidden = YES;
			return;
		}
		
		ABAddressBookRef addressBook = ABAddressBookCreate();
        if (addressBook) {
            ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.entry.person intValue]);
            if (person) {
                self.personId = self.entry.person;
                detailsButton.hidden = NO;
            }
            else {
                detailsButton.hidden = YES;
            }
            CFRelease(addressBook);
        }
	}
}

- (void)contactInfoDidChange
{
	self.personId = nil;
    detailsButton.hidden = YES;
	[contactTableView reloadData];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	[UIView beginAnimations:nil context:NULL];
	if (textField == personTxt) {
		scrollView.contentSize = CGSizeMake(320, 940);
		[scrollView setContentOffset:CGPointMake(0.0, personTxt.frame.origin.y - 80) animated:NO];
		
		[contactTableView setHidden:NO];
		[contactTableView reloadData];
	}
	else {
		[contactTableView setHidden:YES];
		if (textField == dateTxt) {
			[self resignKeyboard];
			DateSelectViewController *controller = [[DateSelectViewController alloc] initWithNibName:@"DateSelectViewController" bundle:nil];
			controller.delegate = self;
			controller.date = self.date;
			controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentModalViewController:controller animated:YES];
			
			[controller release];
			return NO;
		}
		else if (textField == returnDateTxt) {
			[self resignKeyboard];
			ReturnDateSelectViewController *controller = [[ReturnDateSelectViewController alloc] initWithNibName:@"ReturnDateSelectViewController" bundle:nil];
			controller.delegate = self;
			controller.pushAlarm = self.pushAlarmDate;
			controller.date = self.returnDate;
			controller.minDate = self.date;
			controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
			[self presentModalViewController:controller animated:YES];
			[controller release];
			return NO;
		}
		else {
			scrollView.contentSize = CGSizeMake(320, 900);
			[scrollView setContentOffset:CGPointMake(0.0, textField.frame.origin.y -120) animated:NO];
		}

	}
	activeField = textField;
	[UIView commitAnimations];
	return YES;
}

- (void)textFieldDidChange
{
    saveButton.enabled = (([descriptionTxt.text length] > 0) || ([description2Txt.text length] > 0));
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == personTxt) {
		[contactTableView setHidden:YES];
	}
    [self resignKeyboard];
    return NO;
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
	keyboardShown = YES;
}

- (void)keyboardWasHidden:(NSNotification*)aNotification
{
	[UIView beginAnimations:nil context:NULL];
	scrollView.contentSize = CGSizeMake(320, 600);
	keyboardShown = NO;
	[scrollView setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
	[UIView commitAnimations];
}

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifierForValue
{
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [Database getContactCount:personTxt.text];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	ContactEntry *contactEntry = [Database getContactInfo:personTxt.text atIndex:indexPath.row];
	cell.textLabel.text = contactEntry.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ContactEntry *contactEntry = [Database getContactInfo:personTxt.text atIndex:indexPath.row];
	personTxt.text = contactEntry.name;
	self.personId = contactEntry.entryId;
	[detailsButton setHidden:NO];
	[contactTableView setHidden:YES];
	[personTxt resignFirstResponder];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"FromAddressbook", @"");
}

- (IBAction)save
{
	@throw [NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (IBAction)save'" userInfo:nil];
}

- (void)updateStrings
{
	@throw [NSException exceptionWithName:@"Runtime Exception" reason:@"Should be implemented in child class! '- (void)updateStrings'" userInfo:nil];
}
@end
