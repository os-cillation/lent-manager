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

#import "LentOutgoingDetailViewController.h"
#import "Database.h"
#import "ContactEntry.h"
#import "Category.h"


@implementation LentOutgoingDetailViewController

- (IBAction)save
{
	NSString *typeTxt = self.currentCategory.index;
	NSString *description = descriptionTxt.text;
	NSString *description2 = description2Txt.text;
	NSString *personString = self.personId ?: personTxt.text;
	NSString *entryId;
	if (self.entry) {
		entryId = [Database addOutgoingEntry:self.entry.entryId withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:self.date withReturnDate:self.returnDate withPushAlarm:self.pushAlarmDate];
	}
	else {
		entryId = [Database addOutgoingEntry:nil withType:typeTxt withDescription1:description withDescription2:description2 forPerson:personString withDate:self.date withReturnDate:self.returnDate withPushAlarm:self.pushAlarmDate];
	}
	
	Class myClass = NSClassFromString(@"UILocalNotification");
	if (myClass) {
		NSMutableDictionary *list = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushAlarmListOutgoing"] mutableCopy];
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
			[[NSUserDefaults standardUserDefaults] setObject:list forKey:@"PushAlarmListOutgoing"];
		}
		else {
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PushAlarmListOutgoing"];
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
	lentToLabel.text = NSLocalizedString(@"LentToPerson", @"");
	lentFromLabel.text = NSLocalizedString(@"LentToAt", @"");
	lentUntilLabel.text = NSLocalizedString(@"LentToUntil", @"");
	[Util button:deleteDateButton setTitle:NSLocalizedString(@"Clear", @"")];
	[Util button:deleteReturnDateButton setTitle:NSLocalizedString(@"Clear", @"")];
	
	[Util button:buttonType setTitle:[NSString stringWithFormat:NSLocalizedString(@"CategoryText", @""),[Database getDescriptionByIndex:[[self.currentCategory index] intValue]]]];
}

@end
