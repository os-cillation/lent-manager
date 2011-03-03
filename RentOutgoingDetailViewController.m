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
	
	Class myClass = NSClassFromString(@"UILocalNotification");
	if (myClass) {

		NSDictionary *tmpList = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushAlarmListOutgoing"];
		NSMutableDictionary *list;
		if (tmpList) {
			list = [[NSMutableDictionary alloc] initWithDictionary:tmpList];
		}
		else {
			list = [[NSMutableDictionary alloc] init];
		}
		NSData *data = [list objectForKey:entryId];
		
		if (data) {
			UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			[[UIApplication sharedApplication] cancelLocalNotification:notification];
			notification = nil;
			[list removeObjectForKey:entryId];
		}
		
		if (pushAlarmDate) {
			if ([pushAlarmDate compare:[NSDate date]] == NSOrderedDescending) {
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
				UILocalNotification *notification = (UILocalNotification *)[RentManagerAppDelegate createLocalNotification:message withDate:pushAlarmDate forEntry:entryId];
				
				data = [NSKeyedArchiver archivedDataWithRootObject:notification];
				[list setObject:data forKey:entryId];
			}
		}
		if ([list count] == 0) {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListOutgoing"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] setObject:list forKey:@"PushAlarmListOutgoing"];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];

	}
	
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
