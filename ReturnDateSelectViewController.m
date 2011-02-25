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
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
	}
	else {
		datePicker.datePickerMode = UIDatePickerModeDate;
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	labelPush.text = NSLocalizedString(@"PushNotification", @"");
	
	[datePicker setTimeZone:[NSTimeZone systemTimeZone]];
	
	if (!minDate) {
		minDate = [NSDate date];
	}
	
	self.datePicker.minimumDate = minDate;
	if (self.date == nil) {
		self.date = [NSDate date];
	}
	NSDate *currentDate;
	if ([self.date compare:minDate] == NSOrderedDescending) {
		currentDate = minDate;
	}
	else {
		currentDate = self.date;
	}
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit fromDate:currentDate];
	components.day++;
	components.hour = 8;
	currentDate = [calendar dateFromComponents:components];
	
	[self.datePicker setDate:currentDate animated:NO];

	if (pushAlarm) {
		[self.datePicker setDate:pushAlarm animated:NO];
		switchPush.on = YES;
		datePicker.datePickerMode = UIDatePickerModeDateAndTime;
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
	//[datePicker release];
	[date release];
}


@end
