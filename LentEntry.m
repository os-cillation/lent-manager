//
//  LentEntry.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import "Database.h"
#import "LentEntry.h"
#import "NSDateFormatter+DateFormatter.h"


@interface LentEntry ()

- (void)generateTextData;

@end


@implementation LentEntry

#pragma mark -
#pragma mark Synthesized properties

@synthesize entryId = _entryId;
@synthesize type = _type;
@synthesize description = _description;
@synthesize description2 = _description2;
@synthesize person = _person;
@synthesize date = _date;
@synthesize returnDate = _returnDate;
@synthesize firstLine = _firstLine;
@synthesize secondLine = _secondLine;
@synthesize personName = _personName;
@synthesize pushAlarm = _pushAlarm;

#pragma mark -
#pragma mark Constructors and destructors

- (void)dealloc
{
    [_entryId release], _entryId = nil;
    [_type release], _type = nil;
    [_description release], _description = nil;
    [_description2 release], _description2 = nil;
    [_person release], _person = nil;
    [_date release], _date = nil;
    [_returnDate release], _returnDate = nil;
    [_firstLine release], _firstLine = nil;
    [_secondLine release], _secondLine = nil;
    [_personName release], _personName = nil;
    [_pushAlarm release], _pushAlarm = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Derived properties

- (NSString *)dateString
{
    return self.date ? [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:self.date] : @"";
}

- (NSString *)returnDateString
{
    return self.returnDate ? [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:self.returnDate] : @"";
}

#pragma mark -
#pragma mark Database operations

- (void)generateOutgoingText
{
	[self generateTextData];
	[Database addOutgoingText:self.entryId withFirstLine:self.firstLine withSecondLine:self.secondLine withPerson:self.personName];
}

- (void)generateIncomingText
{
	[self generateTextData];
	[Database addIncomingText:self.entryId withFirstLine:self.firstLine withSecondLine:self.secondLine withPerson:self.personName];
}

#pragma mark -
#pragma mark Private methods

- (void)generateTextData
{
    if ([self.description length] && [self.description2 length]) {
        self.firstLine = [NSString stringWithFormat:@"%@ - %@", self.description, self.description2];
    }
    else if ([self.description length]) {
        self.firstLine = self.description;
    }
    else {
        self.firstLine = [NSString stringWithFormat:@"%@", self.description2];
    }
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
    if (addressBook) {
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(addressBook, [self.person intValue]);
        NSString *fullName = @"";
        if (person) {
            self.personName = [(NSString *)ABRecordCopyCompositeName(person) autorelease];
            fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), self.personName];
        }
        else if ([self.person length]) {
            self.personName = self.person;
            fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), self.personName];
        }
        
        if (self.date) {
            if ([fullName length]) {
                self.secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), self.dateString, fullName];
            }
            else {
                self.secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), self.dateString];
            }
        }
        else {
            self.secondLine = fullName;
        }
        
        CFRelease(addressBook);
    }
}


@end
