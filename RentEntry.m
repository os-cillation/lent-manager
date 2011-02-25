//
//  RentEntry.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentEntry.h"
#import <AddressBook/AddressBook.h>
#import "Database.h"


@implementation RentEntry

@synthesize entryId, type, description, description2, person, date, returnDate, firstLine, secondLine, personName, pushAlarm;

- (NSString *)getDateString {
	if (date == nil) {
		return @"";
	}
	NSString *dateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:date];
	[dateFormat release];
	return dateString;
}

- (NSString *)getReturnDateString {
	if (returnDate == nil) {
		return @"";
	}
	NSString *dateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:returnDate];
	[dateFormat release];
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
		fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
	}
	else {
		if ([person length] > 0) {
			personName = person;
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
		}
	}
	
	if (date != nil) {
		if ([fullName length] > 0) {
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), [self getDateString], fullName];
		}
		else {
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), [self getDateString]];
		}
	}
	else {
		secondLine = fullName;
	}
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
