//
//  LentIncomingDetailViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "LentIncomingDetailViewController.h"
#import "Database.h"
#import "DateSelectViewController.h"
#import "ContactEntry.h"
#import "Category.h"


@implementation LentIncomingDetailViewController

- (IBAction)save
{
	NSString *typeTxt = self.currentCategory.index;
	NSString *description = descriptionTxt.text;
	NSString *description2 = description2Txt.text;
	NSString *personString = self.personId ?: personTxt.text;
	NSString *entryId;

	if (self.entry) {
		entryId = [Database addIncomingEntry:self.entry.entryId withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:self.date withReturnDate:self.returnDate withPushAlarm:self.pushAlarmDate];
	}
	else {
		entryId = [Database addIncomingEntry:nil withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:self.date withReturnDate:self.returnDate withPushAlarm:self.pushAlarmDate];
	}
	
	Class myClass = NSClassFromString(@"UILocalNotification");
	if (myClass) {
		NSMutableDictionary *list = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"PushAlarmListIncoming"] mutableCopy];
        if (list) {
            NSData *data = [list objectForKey:entryId];
            if (data) {
                UILocalNotification *notification = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                [list removeObjectForKey:entryId];
            }
        }
        else {
            list = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
		
		if (self.pushAlarmDate) {
			if ([self.pushAlarmDate compare:[NSDate date]] == NSOrderedDescending) {
				NSString *message;
				if ([descriptionTxt.text length] && [description2Txt.text length]) {
					message = [NSString stringWithFormat:@"%@ - %@", descriptionTxt.text, description2Txt.text];
				}
				else if ([descriptionTxt.text length]) {
					message = descriptionTxt.text;
				}
				else {
					message = description2Txt.text;
				}
				UILocalNotification *notification = [LentManagerAppDelegate localNotification:message withDate:self.pushAlarmDate forEntry:entryId];
                if (notification) {
                    [list setObject:[NSKeyedArchiver archivedDataWithRootObject:notification] forKey:entryId];
                }
			}
		}
		if ([list count]) {
			[[NSUserDefaults standardUserDefaults] setObject:list forKey:@"PushAlarmListIncoming"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListIncoming"];
		}
		[[NSUserDefaults standardUserDefaults] synchronize];
        [list release];

	}
	
	[delegate reload];

	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)updateStrings
{
	description1Label.text = NSLocalizedString(@"Author", @"");
	description2Label.text = NSLocalizedString(@"Title", @"");
	lentToLabel.text = NSLocalizedString(@"LentFromPerson", @"");
	lentFromLabel.text = NSLocalizedString(@"LentFromAt", @"");
	lentUntilLabel.text = NSLocalizedString(@"LentFromUntil", @"");
	[Util button:deleteDateButton setTitle:NSLocalizedString(@"Clear", @"")];
	[Util button:deleteReturnDateButton setTitle:NSLocalizedString(@"Clear", @"")];
	
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""), [Database getDescriptionByIndex:[[self.currentCategory index] intValue]]]];
}

@end
