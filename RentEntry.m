//
//  RentEntry.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentEntry.h"


@implementation RentEntry

@synthesize entryId, type, description, description2, person, date, returnDate;

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

@end
