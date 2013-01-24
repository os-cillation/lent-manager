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
	
    minDate = minDate ?: [[NSDate date] retain];
	self.datePicker.minimumDate = minDate;
	if (!self.date) {
		NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit fromDate:[NSDate date]];
		components.day++;
		components.hour = 8;
		self.date = [calendar dateFromComponents:components];
		
		if ([self.date compare:minDate] == NSOrderedAscending) {
			NSDateComponents *components = [calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSHourCalendarUnit fromDate:minDate];
			components.day++;
			components.hour = 8;
			self.date  = [calendar dateFromComponents:components];
		}
	}
    [calendar release];
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
