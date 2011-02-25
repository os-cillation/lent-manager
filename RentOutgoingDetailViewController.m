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
#import "Category.h"


@implementation RentOutgoingDetailViewController

- (IBAction)save {
	NSString *typeTxt = currentCategory.idx;
	NSString *description = descriptionTxt.text;
	NSString *description2 = description2Txt.text;
	NSString *personString = personTxt.text;

	if (personId > 0) {
		personString = personId;
	}
	
	NSString *entryId;
	if (entry != nil) {
		entryId = [Database addOutgoingEntry:entry.entryId withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:date withReturnDate:returnDate withPushAlarm:pushAlarmDate];
	}
	else {
		entryId = [Database addOutgoingEntry:@"NULL" withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:date withReturnDate:returnDate withPushAlarm:pushAlarmDate];
	}
	
#ifdef __IPHONE_4_0

	NSDictionary *tmpList = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushAlarmListOutgoing"];
	if (!tmpList) {
		tmpList = [[NSMutableDictionary alloc] init];
	}
	NSMutableDictionary *list = [[NSMutableDictionary alloc] initWithDictionary:tmpList];
	NSData *data = [list objectForKey:entryId];
	
	if (data) {
		UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		[[UIApplication sharedApplication] cancelLocalNotification:notification];
		notification = nil;
		[list removeObjectForKey:entryId];
	}
	
	if (pushAlarmDate) {
		NSString *message = [NSString stringWithFormat:@"%@ - %@", descriptionTxt.text, description2Txt.text];
		UILocalNotification *notification = [RentManagerAppDelegate createLocalNotification:message withDate:pushAlarmDate];
		
		data = [NSKeyedArchiver archivedDataWithRootObject:notification];
		[list setObject:data forKey:entryId];
	}
	if ([list count] == 0) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListOutgoing"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:@"PushAlarmListOutgoing"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];

#endif
	
	[delegate reload];
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)updateStrings {
	description1Label.text = NSLocalizedString(@"Author", @"");
	description2Label.text = NSLocalizedString(@"Title", @"");
	lentToLabel.text = NSLocalizedString(@"LentToPerson", @"");
	lentFromLabel.text = NSLocalizedString(@"LentToAt", @"");
	lentUntilLabel.text = NSLocalizedString(@"LentToUntil", @"");
	deleteDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	deleteReturnDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""),[Database getDescriptionByIndex:[[currentCategory idx] intValue]]]];
}

@end
