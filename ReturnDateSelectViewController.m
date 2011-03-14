//
//  ReturnDateSelectViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 15.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "ReturnDateSelectViewController.h"


@implementation ReturnDateSelectViewController

@synthesize delegate, datePicker, date, minDate, switchPush, pushAlarm;

- (IBAction)done {
	[delegate returnDateSelectViewControllerDidFinish:self];
}

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)handlePushNotificationsChanged {
	if (switchPush.on) {
		self.datePicker.minimumDate = [NSDate date];
		if ([self.datePicker.date compare:[NSDate date]] == NSOrderedAscending) {
			[self.datePicker setDate:[NSDate date] animated:NO];
		}
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	}
	else {
		datePicker.datePickerMode = UIDatePickerModeDate;
		self.datePicker.minimumDate = minDate;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if (![LentManagerAppDelegate deviceSupportsPush]) {
		labelPush.hidden = YES;
		switchPush.hidden = YES;
	}
	
	labelPush.text = NSLocalizedString(@"PushNotification", @"");
	
	[datePicker setTimeZone:[NSTimeZone systemTimeZone]];
	
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	
	if (!minDate) {
		minDate = [[NSDate date] retain];
	}
	
	self.datePicker.minimumDate = minDate;
	if (self.date == nil) {
		NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
		components.day++;
		components.hour = 8;
		self.date  = [calendar dateFromComponents:components];
		
		if ([self.date compare:minDate] == NSOrderedAscending) {
			NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit fromDate:minDate];
			components.day++;
			components.hour = 8;
			self.date  = [calendar dateFromComponents:components];
		}
	}
	[self.datePicker setDate:self.date animated:NO];

	if (pushAlarm) {
		if ([pushAlarm compare:[NSDate date]] == NSOrderedDescending) {
			[self.datePicker setDate:pushAlarm animated:NO];
			switchPush.on = YES;
			datePicker.datePickerMode = UIDatePickerModeDateAndTime;
		}
	}
}

- (void)dealloc {
	[date release];
	[minDate release];
	[pushAlarm release];
    [super dealloc];
}


@end
