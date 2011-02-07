//
//  Database.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "Database.h"
#import "RentEntry.h"
#import <AddressBook/AddressBook.h>


@implementation Database

+ (void)createEditableCopyOfDatabaseIfNeeded {
	//NSLog(@"Creating editable copy of database...");

	BOOL success;
	NSFileManager *fileManager = [NSFileManager alloc];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) return;
	//[fileManager removeItemAtPath:writableDBPath error:&error];
	// The writeable database does not exist, so copy the default to the appropriate location
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.sqlite"];

	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		// NSAssert1(0, @"Failed to create writeable database file with message'%@'.", [error localizedDescription]);
	}
}

+ (sqlite3 *) getNewDBConnection {
	sqlite3 *db;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	// Open the database.
	if (sqlite3_open([path UTF8String], &db) == SQLITE_OK) {
		//NSLog(@"Databases successfully opened...");
	}
	else {
		//NSLog(@"Error while openening database...");
	}
	

	sqlite3_stmt *statement = nil;
	const char* sql;
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS rentIncoming(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, description1 TEXT, description2 TEXT, person TEXT, date DATE, returnDate Date);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS rentOutgoing(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, description1 TEXT, description2 TEXT, person TEXT, date DATE, returnDate Date);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS outgoingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS incomingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	
//	[Database updateDB:db];
	connection = db;
	return db;
}

+ (sqlite3 *)getConnection {
	if (connection == nil || connection == NULL) {
		//NSLog(@"create a new database instance...");
		[Database getNewDBConnection];
		[NSThread detachNewThreadSelector:@selector(prepareContactInfo) toTarget:self withObject:nil];
	}
	return connection;
}

+ (void)prepareContactInfo{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char* sql;
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS contactInfo(id INTEGER PRIMARY KEY, name TEXT);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "DELETE FROM contactInfo;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	ABAddressBookRef ab = ABAddressBookCreate();
	
	CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(ab);
	
	for (CFIndex i = CFArrayGetCount(contacts)-1; i >= 0; i--) {
		ABRecordRef	person = (ABRecordRef) CFArrayGetValueAtIndex(contacts, i);
		
		ABRecordID id = ABRecordGetRecordID(person);
		
		NSString *personId = [NSString stringWithFormat:@"%i", id];
		
		NSString* firstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
		NSString* lastName = (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);		

		NSString *fullName = [NSString alloc];
		if ((firstName == NULL) && (lastName == NULL)) {
			fullName = (NSString *)ABRecordCopyValue(person, kABPersonOrganizationProperty);
		}
		else if ((firstName == NULL) || (lastName == NULL)) {
			if (firstName == NULL) {
				fullName = lastName;
			}
			if (lastName == NULL) {
				fullName = firstName;
			}
		}
		else {
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", firstName, lastName];
		}
		
		statement = nil;
		NSString *sqlString = [[NSString alloc] initWithFormat:@"insert into contactInfo(id, name) Values('%@', ?);", personId];
		sql = [sqlString cString];
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_bind_text(statement, 1, [fullName UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}
	
	[pool release];
}

+ (ContactEntry *)getContactInfo:(NSString *)filter atIndex:(int)index {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [NSString alloc];
	
	if (filter == nil || [filter length] == 0) {
		
		sqlString = [[NSString alloc] initWithFormat:@"SELECT * from contactInfo ORDER BY name LIMIT %i,1;", index];
	}
	else {
		sqlString = @"SELECT * from contactInfo where name LIKE ? order by name LIMIT";
		sqlString = [sqlString stringByAppendingFormat:@" %i,1;", index];
	}
	
	
	const char* sql = [sqlString cString]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"sql:  %s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			ContactEntry *entry = [ContactEntry alloc];
			entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			
			const char *name = (const char *) sqlite3_column_text(statement,1);
			
			if (name != NULL) {
				entry.name = [NSString stringWithUTF8String:name];
			}
			
			sqlite3_finalize(statement);
			return entry;
		}
	}
	sqlite3_finalize(statement);
	
	return nil;
}

+ (int)getContactCount:(NSString *)filter {
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [NSString alloc];
	
	if (filter == nil || [filter length] == 0) {
		
		sqlString = [[NSString alloc] initWithFormat:@"SELECT count(*) from contactInfo"];
	}
	else {
		sqlString = @"SELECT count(*) from contactInfo where name LIKE ?;";
	}
	
	const char* sql = [sqlString cString]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", filter];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *countString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			count = [countString intValue];
		}
	}
	sqlite3_finalize(statement);
	return count;
}

+ (NSString *)getDescriptionByIndex:(int)index {
	switch (index) {
		case 0:
			return NSLocalizedString(@"Book", @"");
		case 1:
			return NSLocalizedString(@"CD", @"");
		case 2:
			return NSLocalizedString(@"DVD", @"");
		case 3:
			return NSLocalizedString(@"Other", @"");
		default:
			break;
	}
	return NSLocalizedString(@"Other", @"");
}

+ (RentList *)getIncomingEntries:(NSString *)searchText {
//	NSLog(@"start getting incoming entries...");
	RentList *list = [[RentList alloc] init];
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	for (int index = 0; index < 4; index++) {
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];
		NSString *sqlString = [NSString alloc];
		NSString *filter = [NSString alloc];
	
	if (searchText == nil || [searchText length] == 0) {
		
		sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name from rentIncoming NATURAL LEFT JOIN incomingText where type='";
		sqlString = [sqlString stringByAppendingFormat:@"%i", index];
		
		sqlString = [sqlString stringByAppendingString:@"' order by name;"];
	}
	else {
		sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name from rentIncoming NATURAL LEFT JOIN incomingText where type='";
		sqlString = [sqlString stringByAppendingFormat:@"%i", index];
		sqlString = [sqlString stringByAppendingString:@"' AND name LIKE ? order by name;"];
	}
	
	const char* sql = [sqlString cString]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		filter = [[NSString alloc] initWithFormat:@"%%%@%%", searchText];
		sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
			RentEntry *entry = [RentEntry alloc];
			entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
			NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
			NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
			
			const char *description = (const char *) sqlite3_column_text(statement,2);
			const char *description2 = (const char *)sqlite3_column_text(statement,3);
			const char *person = (const char *)sqlite3_column_text(statement,4);
			const char *firstLine = (const char *)sqlite3_column_text(statement,7);
			const char *secondLine = (const char *)sqlite3_column_text(statement,8);
			const char *personName = (const char *)sqlite3_column_text(statement,9);
			if (description != NULL) {
				entry.description = [NSString stringWithUTF8String:description];
			}
			if (description2 != NULL) {
				entry.description2 = [NSString stringWithUTF8String:description2];
			}
			if (person != NULL) {
				entry.person = [NSString stringWithUTF8String:person];
			}
			if (firstLine != NULL) {
				entry.firstLine = [NSString stringWithUTF8String:firstLine];
			}
			if (secondLine != NULL) {
				entry.secondLine = [NSString stringWithUTF8String:secondLine];
			}
			if (personName != NULL) {
				entry.personName = [NSString stringWithUTF8String:personName];
			}
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
			NSDate *date = [dateFormat dateFromString:dateString];  
			NSDate *returnDate = [dateFormat dateFromString:returnDateString];
			[dateFormat release];
			
			entry.date = date;
			entry.returnDate = returnDate;
			
			//[entry generateData];
			
			[listEntry addObject:entry];
			[entry release];
		}
	}
	sqlite3_finalize(statement);
	
	if ([listEntry count] > 0) {
		[data addObject:listEntry];
	}
	}
	[list setData:data];
//	NSLog(@"finish getting entries...");
	return list;
}

+ (RentList *)getOutgoingEntries:(NSString *)searchText {
//	NSLog(@"start getting outgoing entries...");
	RentList *list = [[RentList alloc] init];
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	for (int index = 0; index < 4; index++) {
		statement = nil;
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];
		NSString *sqlString = [NSString alloc];
		NSString *filter = [NSString alloc];
		
		if (searchText == nil || [searchText length] == 0) {
			
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name from rentOutgoing NATURAL LEFT JOIN outgoingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", index];
			
			sqlString = [sqlString stringByAppendingString:@"' order by name;"];
		}
		else {
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name from rentOutgoing NATURAL LEFT JOIN outgoingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", index];
			sqlString = [sqlString stringByAppendingString:@"' AND name LIKE ? order by name;"];
		}
		//NSLog(@"%@", sqlString);
		const char* sql = [sqlString cString]; 
		
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"error preparing statement...");
			NSLog(@"%s",sql);
		}
		else {
			filter = [[NSString alloc] initWithFormat:@"%%%@%%", searchText];
			sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
			while (sqlite3_step(statement) == SQLITE_ROW) {
				RentEntry *entry = [RentEntry alloc];
				entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
				entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
				NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
				NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
				
				const char *description = (const char *) sqlite3_column_text(statement,2);
				const char *description2 = (const char *)sqlite3_column_text(statement,3);
				const char *person = (const char *)sqlite3_column_text(statement,4);
				const char *firstLine = (const char *) sqlite3_column_text(statement,7);
				const char *secondLine = (const char *) sqlite3_column_text(statement,8);
				const char *personName = (const char *) sqlite3_column_text(statement,9);

				if (description != NULL) {
					entry.description = [NSString stringWithUTF8String:description];
				}
				if (description2 != NULL) {
					entry.description2 = [NSString stringWithUTF8String:description2];
				}
				if (person != NULL) {
					entry.person = [NSString stringWithUTF8String:person];
				}
				if (firstLine != NULL) {
					entry.firstLine = [NSString stringWithUTF8String:firstLine];
				}
				if (secondLine != NULL) {
					entry.secondLine = [NSString stringWithUTF8String:secondLine];
				}
				if (personName != NULL) {
					entry.personName = [NSString stringWithUTF8String:personName];
				}
				
				NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
				[dateFormat setDateFormat:@"yyyy-MM-dd"];
				NSDate *date = [dateFormat dateFromString:dateString];  
				NSDate *returnDate = [dateFormat dateFromString:returnDateString];
				[dateFormat release];
				
				entry.date = date;
				entry.returnDate = returnDate;
				
				//[entry generateData];
				
				[listEntry addObject:entry];
				[entry release];
			}
		}
		sqlite3_finalize(statement);
		
		if ([listEntry count] > 0) {
			[data addObject:listEntry];
		}
	}
	[list setData:data];
//	NSLog(@"finish getting entries...");
	return list;
}
	
+ (void)addOutgoingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate {
//	NSLog(@"Add entry...");
	sqlite3 *db = [Database getConnection];
	const char *sql;
	
	sqlite3_stmt *addStmt = nil;
	
	NSString *dateString = [NSString alloc];
	NSString *returnDateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	dateString = [dateFormat stringFromDate:date];
	
	returnDateString = [dateFormat stringFromDate:returnDate];
	
	if([entryId intValue] > 0) {
		sql = "insert or replace into rentOutgoing(id, type, description1, description2, person, date, returnDate) Values(?, ?, ?, ?, ?, ?, ?)";
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(addStmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);	
		sqlite3_bind_text(addStmt, 2, [type UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [((description1 != NULL) ? description1 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [((description2 != NULL) ? description2 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 5, [((person != NULL) ? person : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 6, [dateString UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 7, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
	}
	else {
		sql = "insert or replace into rentOutgoing(type, description1, description2, person, date, returnDate) Values(?, ?, ?, ?, ?, ?)";
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(addStmt, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 2, [((description1 != NULL) ? description1 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [((description2 != NULL) ? description2 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [((person != NULL) ? person : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 5, [dateString UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 6, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
	}	
	
	if(SQLITE_DONE != sqlite3_step(addStmt)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	
	if ([entryId intValue] <= 0) {
		entryId = [[NSString alloc] initWithFormat:@"%i", sqlite3_last_insert_rowid(db)];
	}
	
	sqlite3_reset(addStmt);
	
	dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:date];
	
	[dateFormat release];
	
	NSString *firstLine = @"";
	NSString *secondLine = @"";
	
	if ([description1 length] == 0 || [description2 length] == 0) {
		if ([description1 length] == 0 ) {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description2];
		}
		else {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description1];
		}
	}
	else {
		firstLine = [[NSString alloc] initWithFormat:@"%@ - %@", description1, description2];
	}
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [person intValue]);
	
	NSString *fullName = @"";
	NSString *personName = @"";
	
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
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), dateString, fullName];
		}
		else {
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), dateString];
		}
	}
	else {
		secondLine = fullName;
	}
	
	
	addStmt = nil;
	
	if(addStmt == nil) {
		sql = "insert or replace into outgoingText(id, firstLine, secondLine, personName) Values(?, ?, ?, ?)";
		
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(addStmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);
	
}

+ (void)addIncomingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate {
//	NSLog(@"Add entry...");
	sqlite3 *db = [Database getConnection];
	const char *sql;
	
	
	NSString *dateString = [NSString alloc];
	NSString *returnDateString = [NSString alloc];
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	dateString = [dateFormat stringFromDate:date];
	
	returnDateString = [dateFormat stringFromDate:returnDate];	
	
	sqlite3_stmt *addStmt = nil;
	
	if ([entryId intValue] > 0) {
		sql = "insert or replace into rentIncoming(id, type, description1, description2, person, date, returnDate) Values(?, ?, ?, ?, ?, ?, ?)";

		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(addStmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 2, [type UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [((description1 != NULL) ? description1 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [((description2 != NULL) ? description2 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 5, [((person != NULL) ? person : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 6, [((dateString != NULL) ? dateString : @"")  UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 7, [((returnDateString != NULL) ? returnDateString : @"") UTF8String], -1, SQLITE_TRANSIENT);
	}
	else {
		sql = "insert or replace into rentIncoming(type, description1, description2, person, date, returnDate) Values(?, ?, ?, ?, ?, ?)";
		
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			NSLog(@"%s", sql);
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(addStmt, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 2, [((description1 != NULL) ? description1 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [((description2 != NULL) ? description2 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [((person != NULL) ? person : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 5, [((dateString != NULL) ? dateString : @"")  UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 6, [((returnDateString != NULL) ? returnDateString : @"") UTF8String], -1, SQLITE_TRANSIENT);
	}
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);

	if ([entryId intValue] <= 0) {
			entryId = [[NSString alloc] initWithFormat:@"%i", sqlite3_last_insert_rowid(db)];
	}
	
	
	dateFormat = [[NSDateFormatter alloc] init]; 
	
	[dateFormat setDateFormat:@"dd.MM.yyyy"];
	dateString = [dateFormat stringFromDate:returnDate];
	
	[dateFormat release];
	
	NSString *firstLine = @"";
	NSString *secondLine = @"";
	
	if ([description1 length] == 0 || [description2 length] == 0) {
		if ([description1 length] == 0 ) {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description2];
		}
		else {
			firstLine = [[NSString alloc] initWithFormat:@"%@", description1];
		}
	}
	else {
		firstLine = [[NSString alloc] initWithFormat:@"%@ - %@", description1, description2];
	}
	
	ABAddressBookRef ab = ABAddressBookCreate();
	ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [person intValue]);
	
	NSString *fullName = @"";
	NSString *personName = @"";
	
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
		fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
	}
	else {
		if ([person length] > 0) {
			personName = person;
			fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
		}
	}
	
	if (returnDate != nil) {
		if ([fullName length] > 0) {
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"until", @""), dateString, fullName];
		}
		else {
			secondLine = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"until", @""), dateString];
		}
	}
	else {
		secondLine = fullName;
	}
	
	
	addStmt = nil;
	
	
	if(addStmt == nil) {
		sql = "insert or replace into incomingText(id, firstLine, secondLine, personName) Values(?, ?, ?, ?)";
		
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(addStmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);
}

+ (void)deleteIncomingEntry:(NSString *)entryId {
//	NSLog(@"Remove entry...");
	sqlite3 *db = [Database getConnection];
	
	sqlite3_stmt *stmt = nil;
	
	if(stmt == nil) {
		const char *sql = "delete from rentIncoming where id = ?";
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(stmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(stmt)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(stmt);
	
	stmt = nil;
	
	if(stmt == nil) {
		const char *sql = "delete from incomingText where id = ?";
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(stmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(stmt)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(stmt);
}

+ (void)deleteOutgoingEntry:(NSString *)entryId {
//	NSLog(@"Remove entry...");
	sqlite3 *db = [Database getConnection];
	
	sqlite3_stmt *stmt = nil;
	
	if(stmt == nil) {
		const char *sql = "delete from rentOutgoing where id = ?";
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			// NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(stmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(stmt)) {
		// NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(stmt);
	
	stmt = nil;
	
	if(stmt == nil) {
		const char *sql = "delete from outgoingText where id = ?";
		if(sqlite3_prepare_v2(db, sql, -1, &stmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(stmt, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(stmt)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(stmt);
}

+ (int)getIncomingCount {
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [NSString alloc];	
	
	sqlString = [[NSString alloc] initWithFormat:@"SELECT count(*) from rentIncoming"];
	
	const char *sql = [sqlString cString]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *countString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			count += [countString intValue];
		}
	}
	sqlite3_finalize(statement);
	return count;
}

+ (int)getOutgoingCount {
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString = [NSString alloc];
	
	
	sqlString = [[NSString alloc] initWithFormat:@"SELECT count(*) from rentOutgoing"];
	
	const char *sql = [sqlString cString]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *countString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			count += [countString intValue];
		}
	}
	sqlite3_finalize(statement);
	return count;
}

+ (int)getEntryCount {
	int count = 0;
	
	count += [Database getIncomingCount];
	count += [Database getOutgoingCount];
	
	return count;
}

+ (void)addIncomingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *addStmt = nil;
	
	if(addStmt == nil) {
		const char *sql = "insert into incomingText(id, firstLine, secondLine, personName) Values(?, ?, ?, ?)";
		
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(addStmt, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);
}

+ (void)addOutgoingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *addStmt = nil;
	
	if(addStmt == nil) {
		const char *sql = "insert into outgoingText(id, firstLine, secondLine, personName) Values(?, ?, ?, ?)";
		
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
	}
	
	sqlite3_bind_text(addStmt, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);
}

/*
+ (void)updateDB:(sqlite3 *)db {	
	BOOL updateDB = [[NSUserDefaults standardUserDefaults] boolForKey:@"updateDB"];
	if (TRUE || updateDB) {
		
		NSLog(@"update db...");
		[[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:@"updateDB"];

		[Database prepareOutgoingText:db];
		[Database prepareIncomingText:db];
	}
}

+ (void)prepareOutgoingText:(sqlite3 *)db {
	
//	sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char* sql;
	
	statement = nil;
	sql = "DROP TABLE IF EXISTS outgoingText;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS outgoingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);";

	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "DELETE FROM outgoingText;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	return;
	
	sql = "SELECT id, description1, description2, person, date from rentOutgoing;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *id = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 4)];

			NSString *description1 = @"";
			NSString *description2 = @"";
			NSString *person = @"";
			const char *tmp = (const char *) sqlite3_column_text(statement,1);
			if (tmp != NULL) {
				description1 = [NSString stringWithUTF8String:tmp];
			}
			tmp = (const char *)sqlite3_column_text(statement,2);
			if (tmp != NULL) {
				description2 = [NSString stringWithUTF8String:tmp];
			}
			tmp = (const char *)sqlite3_column_text(statement,3);
			if (tmp != NULL) {
				person = [NSString stringWithUTF8String:tmp];
			}
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
			NSDate *date = [dateFormat dateFromString:dateString];  
			
			dateFormat = [[NSDateFormatter alloc] init]; 
			
			[dateFormat setDateFormat:@"dd.MM.yyyy"];
			dateString = [dateFormat stringFromDate:date];
			
			[dateFormat release];
			
			NSString *firstLine = @"";
			NSString *secondLine = @"";
			
			if ([description1 length] == 0 || [description2 length] == 0) {
				if ([description1 length] == 0 ) {
					firstLine = [[NSString alloc] initWithFormat:@"%@", description2];
				}
				else {
					firstLine = [[NSString alloc] initWithFormat:@"%@", description1];
				}
			}
			else {
				firstLine = [[NSString alloc] initWithFormat:@"%@ - %@", description1, description2];
			}
			
			ABAddressBookRef ab = ABAddressBookCreate();
			ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [person intValue]);
			
			NSString *fullName = @"";
			NSString *personName = @"";
			
			if (personRef > 0) {
				NSString *firstName = (NSString *)ABRecordCopyValue(personRef, kABPersonFirstNameProperty);
				NSString *lastName = (NSString *)ABRecordCopyValue(personRef, kABPersonLastNameProperty);				
				
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
					secondLine = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), dateString, fullName];
				}
				else {
					secondLine = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), dateString];
				}
			}
			else {
				secondLine = fullName;
			}

			
			sqlite3_stmt *addStmt = nil;
			
			if(addStmt == nil) {
				sql = "insert into outgoingText(id, firstLine, secondLine, personName) Values(?, ?, ?, ?)";

				if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
					//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
				}
			}
			
			sqlite3_bind_text(addStmt, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(addStmt)){
				//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
			}
			sqlite3_reset(addStmt);
		}
	}
	sqlite3_finalize(statement);
}

+ (void)prepareIncomingText:(sqlite3 *)db {
	
	//sqlite3 *db = connection;
	sqlite3_stmt *statement = nil;
	const char* sql;
	
	statement = nil;
	sql = "DROP TABLE IF EXISTS incomingText;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);

	
	statement = nil;
	sql = "CREATE TABLE IF NOT EXISTS incomingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	statement = nil;
	sql = "DELETE FROM incomingText;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	sqlite3_step(statement);
	sqlite3_finalize(statement);
	return;
	
	sql = "SELECT id, description1, description2, person, returnDate from rentIncoming;";
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			NSString *id = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 4)];
			
			NSString *description1 = @"";
			NSString *description2 = @"";
			NSString *person = @"";
			const char *tmp = (const char *) sqlite3_column_text(statement,1);
			if (tmp != NULL) {
				description1 = [NSString stringWithUTF8String:tmp];
			}
			tmp = (const char *)sqlite3_column_text(statement,2);
			if (tmp != NULL) {
				description2 = [NSString stringWithUTF8String:tmp];
			}
			tmp = (const char *)sqlite3_column_text(statement,3);
			if (tmp != NULL) {
				person = [NSString stringWithUTF8String:tmp];
			}
			
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
			NSDate *date = [dateFormat dateFromString:dateString];  
			
			dateFormat = [[NSDateFormatter alloc] init]; 
			
			[dateFormat setDateFormat:@"dd.MM.yyyy"];
			dateString = [dateFormat stringFromDate:date];
			
			[dateFormat release];
			
			NSString *firstLine = @"";
			NSString *secondLine = @"";
			
			if ([description1 length] == 0 || [description2 length] == 0) {
				if ([description1 length] == 0 ) {
					firstLine = [[NSString alloc] initWithFormat:@"%@", description2];
				}
				else {
					firstLine = [[NSString alloc] initWithFormat:@"%@", description1];
				}
			}
			else {
				firstLine = [[NSString alloc] initWithFormat:@"%@ - %@", description1, description2];
			}
			
			ABAddressBookRef ab = ABAddressBookCreate();
			ABRecordRef personRef = ABAddressBookGetPersonWithRecordID(ab, [person intValue]);
			
			NSString *fullName = @"";
			NSString *personName = @"";
			
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
				fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
			}
			else {
				if ([person length] > 0) {
					personName = person;
					fullName = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
				}
			}
			
			if (date != nil) {
				if ([fullName length] > 0) {
					secondLine = [[NSString alloc] initWithFormat:@"%@ %@, %@", NSLocalizedString(@"until", @""), dateString, fullName];
				}
				else {
					secondLine = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"until", @""), dateString];
				}
			}
			else {
				secondLine = fullName;
			}
			
			
			sqlite3_stmt *addStmt = nil;
			
			if(addStmt == nil) {
				sql = "insert into incomingText(id, firstLine, secondLine) Values(?, ?, ?)";
				
				if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
					//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
				}
			}
			
			sqlite3_bind_text(addStmt, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 2, [((firstLine != NULL) ? firstLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 3, [((secondLine != NULL) ? secondLine : @"") UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(addStmt, 4, [((personName != NULL) ? personName : @"") UTF8String], -1, SQLITE_TRANSIENT);
			
			if(SQLITE_DONE != sqlite3_step(addStmt)){
				//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
			}
			sqlite3_reset(addStmt);
		}
	}
	sqlite3_finalize(statement);
}
*/


@end
