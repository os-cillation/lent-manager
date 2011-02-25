//
//  AddEntryViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentIncomingDetailViewController.h"
#import "Database.h"
#import "DateSelectViewController.h"
#import "ContactEntry.h"
#import "Category.h"


@implementation RentIncomingDetailViewController

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
		entryId = [Database addIncomingEntry:entry.entryId withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:date withReturnDate:returnDate withPushAlarm:pushAlarmDate];
	}
	else {
		entryId = [Database addIncomingEntry:@"NULL" withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:date withReturnDate:returnDate withPushAlarm:pushAlarmDate];
	}
	
#ifdef __IPHONE_4_0

	NSDictionary *tmpList = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PushAlarmListIncoming"];
	if (!tmpList) {
		tmpList = [[NSDictionary alloc] init];
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
		NSString *message;
		if (([descriptionTxt.text length] > 0) && ([description2Txt.text length] > 0)) {
			message = [NSString stringWithFormat:@"%@ - %@", descriptionTxt.text, description2Txt.text];
		}
		else if (([descriptionTxt.text length] > 0)) {
			message = descriptionTxt.text;
		}
		else {
			message = description2Txt.text;
		}


		
		UILocalNotification *notification = [RentManagerAppDelegate createLocalNotification:message withDate:pushAlarmDate];
		
		data = [NSKeyedArchiver archivedDataWithRootObject:notification];
		[list setObject:data forKey:entryId];
	}
	if ([list count] == 0) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListIncoming"];
	}
	else {
		[[NSUserDefaults standardUserDefaults] setObject:list forKey:@"PushAlarmListIncoming"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];

#endif
	
	[delegate reload];

	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)updateStrings {
	description1Label.text = NSLocalizedString(@"Author", @"");
	description2Label.text = NSLocalizedString(@"Title", @"");
	lentToLabel.text = NSLocalizedString(@"LentFromPerson", @"");
	lentFromLabel.text = NSLocalizedString(@"LentFromAt", @"");
	lentUntilLabel.text = NSLocalizedString(@"LentFromUntil", @"");
	deleteDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	deleteReturnDateButton.titleLabel.text = NSLocalizedString(@"Clear", @"");
	
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""), [Database getDescriptionByIndex:[[currentCategory idx] intValue]]]];
}

@end
