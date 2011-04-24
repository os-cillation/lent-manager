//
//  LentEntry.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "LentEntry.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"


@implementation LentEntry

@synthesize entryId, type, description, description2, person, date, returnDate, firstLine, secondLine, personName, pushAlarm;

- (NSString *)getDateString {
	if (date == nil) {
		return @"";
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateString = [formatter stringForObjectValue:date];
	[formatter release];
	return dateString;
}

- (NSString *)getReturnDateString {
	if (returnDate == nil) {
		return @"";
	}
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	NSString *dateString = [formatter stringForObjectValue:returnDate];
	[formatter release];
	return dateString;
}

- (void)generateOutgoingText {
	[self generateTextData];
	[Database addOutgoingText:entryId withFirstLine:firstLine withSecondLine:secondLine withPerson:personName];
}

- (void)generateIncomingText {
	[self generateTextData];
	[Database addIncomingText:entryId withFirstLine:firstLine withSecondLine:secondLine withPerson:personName];
}


- (void)generateTextData {
	if ([description length] == 0 || [description2 length] == 0) {
		if ([description length] == 0 ) {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description2];
		}
		else {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description];
		}
	}
	else {
		firstLine = [[NSString alloc] initWithFormat:@"%@ - %@", description, description2];
	}
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [person intValue]);
	
	NSString *fullName = @"";
    if (personRef) {
        if (personRef > 0) {
            NSString* firstName = (NSString *)ABRecordCopyValue(personRef, kABPersonFirstNameProperty);
            NSString* lastName = (NSString *)ABRecordCopyValue(personRef, kABPersonLastNameProperty);
            
            
            if (firstName == nil || lastName == nil) {
                if (firstName == nil) {
                    personName = lastName;
                }
                else {
                    personName = firstName;
                }
            }
            else {
                personName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
            }
            fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
            [firstName release];
            [lastName release];
        }
        else {
            if ([person length] > 0) {
                personName = person;
                fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
            }
        }
        
        if (date != nil) {
            if ([fullName length] > 0) {
                secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), [self getDateString], fullName];
            }
            else {
                secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), [self getDateString]];
            }
        }
        else {
            secondLine = fullName;
        }
    }
    CFRelease(ab);
}

- (void)dealloc {
	[entryId release];
	[type release];
	[description release];
	[description2 release];
	[person release];
	[date release];
	[returnDate release];
	[firstLine release];
	[secondLine release];
	[personName release];
	[pushAlarm release];
	[super dealloc];
}


@end