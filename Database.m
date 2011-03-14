//
//  Database.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "Database.h"
#import "LentEntry.h"
#import "Category.h"
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
	[fileManager release];
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
	
	
	
	
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"DatabaseUpdated_1.0.0"]) {
		[[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"DatabaseUpdated_1.0.0"];
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS rentIncoming(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, description1 TEXT, description2 TEXT, person TEXT, date DATE, returnDate Date, pushAlarm DateTime);", NULL, NULL, NULL);
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS rentOutgoing(id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT, description1 TEXT, description2 TEXT, person TEXT, date DATE, returnDate Date, pushAlarm DateTime);", NULL, NULL, NULL);
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS outgoingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);", NULL, NULL, NULL);
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS incomingText(id INTEGER PRIMARY KEY, firstLine TEXT, secondLine TEXT, personName TEXT);", NULL, NULL, NULL);
		sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, preDefined TINYINT);", NULL, NULL, NULL);
		sqlite3_exec(db, "INSERT INTO categories(id, name, preDefined) VALUES (0, 'Book', 1);", NULL, NULL, NULL);
		sqlite3_exec(db, "INSERT INTO categories(id, name, preDefined) VALUES (1, 'CD', 1);", NULL, NULL, NULL);
		sqlite3_exec(db, "INSERT INTO categories(id, name, preDefined) VALUES (2, 'DVD', 1);", NULL, NULL, NULL);
		sqlite3_exec(db, "INSERT INTO categories(id, name, preDefined) VALUES (3, 'Other', 1);", NULL, NULL, NULL);
		sqlite3_exec(db, "INSERT INTO categories(id, name, preDefined) VALUES (4, 'Money', 1);", NULL, NULL, NULL);
		sqlite3_exec(db, "ALTER TABLE rentIncoming ADD COLUMN pushAlarm DateTime;", NULL, NULL, NULL);
		sqlite3_exec(db, "ALTER TABLE rentOutgoing ADD COLUMN pushAlarm DateTime;", NULL, NULL, NULL);
		
		NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO categories(name, preDefined) VALUES ('%@', 0);", NSLocalizedString(@"Ballpen",@"")];
		sqlite3_exec(db,[sqlString cStringUsingEncoding:NSISOLatin1StringEncoding] , NULL, NULL, NULL);
		sqlString = [NSString stringWithFormat:@"INSERT INTO categories(name, preDefined) VALUES ('%@', 0);", NSLocalizedString(@"Tool",@"")];
		sqlite3_exec(db,[sqlString cStringUsingEncoding:NSISOLatin1StringEncoding] , NULL, NULL, NULL);
	}
	
	connection = db;
	
	[Database prepareContactInfo];
	
	return db;
}

+ (sqlite3 *)getConnection {
	if (connection == nil || connection == NULL) {
		//NSLog(@"create a new database instance...");
		[Database getNewDBConnection];
	}
	return connection;
}

+ (void)prepareContactInfo{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	sqlite3 *db = connection;
	sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
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

		NSString *fullName;
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
			fullName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		}
		if ([fullName length] == 0) {
			continue;
		}
		
		statement = nil;
		NSString *sqlString = [NSString stringWithFormat:@"INSERT INTO contactInfo(id, name) Values('%@', ?);", personId];
		sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding];
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		sqlite3_bind_text(statement, 1, [fullName UTF8String], -1, SQLITE_TRANSIENT);
		
		sqlite3_step(statement);
		sqlite3_finalize(statement);
	}
	sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
	
	[pool release];
}

+ (ContactEntry *)getContactInfo:(NSString *)filter atIndex:(int)index {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString;
	
	if (filter == nil || [filter length] == 0) {
		
		sqlString = [NSString stringWithFormat:@"SELECT id, name FROM contactInfo ORDER BY name LIMIT %i,1;", index];
	}
	else {
		sqlString = @"SELECT id, name FROM contactInfo WHERE name LIKE ? order by name LIMIT";
		sqlString = [sqlString stringByAppendingFormat:@" %i,1;", index];
	}
	
	
	const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"sql:  %s",sql);
	}
	else {
		filter = [NSString stringWithFormat:@"%%%@%%", filter];
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
	
	NSString *sqlString;
	
	if (filter == nil || [filter length] == 0) {
		
		sqlString = [NSString stringWithFormat:@"SELECT count(*) from contactInfo"];
	}
	else {
		sqlString = @"SELECT count(*) from contactInfo where name LIKE ?;";
	}
	
	const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		filter = [NSString stringWithFormat:@"%%%@%%", filter];
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
	NSString *description = NSLocalizedString(@"Other", @"");
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT id, name, preDefined FROM categories WHERE id = %i", index];
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSISOLatin1StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%@",sql);
	}
	else {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			description = [[NSString alloc] initWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
			if (sqlite3_column_int(statement, 2) == 1) {
				description = NSLocalizedString(description, @"");
			}
		}
	}
	return description;
}

+ (int)getCategoryCount {
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT count(1) FROM categories WHERE 1"];
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSISOLatin1StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%@",sql);
	}
	else {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			count = sqlite3_column_int(statement, 0);
		}
	}
	return count;
}

+ (NSArray *)getAllCategories {
	NSMutableArray *tmp = [[NSMutableArray alloc] init];

	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT id, name, preDefined FROM categories WHERE 1"];
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSISOLatin1StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%@",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Category *category = [[Category alloc] init];
			category.idx = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			const char *categoryName = (const char *) sqlite3_column_text(statement,1);
			
			if (categoryName != NULL) {
				category.name = [NSString stringWithUTF8String:categoryName];
			}
			if (sqlite3_column_int(statement, 2) == 1) {
				category.name = NSLocalizedString(category.name, @"");
			}
			[tmp addObject:category];
			[category release];
		}
	}
	
	NSSortDescriptor *sorter = [[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease];
	NSArray *data = [[NSArray alloc] initWithArray:tmp];
	data = [data sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
	return data;
}

+ (Category *)getCategory:(NSString *)idx {
	Category *category = [[Category alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
		NSString *sql = [NSString stringWithFormat:@"SELECT id, name, preDefined FROM categories WHERE id = %@ ORDER BY name ASC", idx];
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSISOLatin1StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%@",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			category.idx = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			const char *categoryName = (const char *) sqlite3_column_text(statement,1);
			
			if (categoryName != NULL) {
				category.name = [NSString stringWithUTF8String:categoryName];
			}
			if (sqlite3_column_int(statement, 2) == 1) {
				category.name = NSLocalizedString(category.name, @"");
			}
		}
	}
	return category;
}

+ (NSMutableArray *)getAllOwnCategories {
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sql = [NSString stringWithFormat:@"SELECT id, name, preDefined FROM categories WHERE predefined = 0 ORDER BY name ASC"];
	if (sqlite3_prepare_v2(db, [sql cStringUsingEncoding:NSISOLatin1StringEncoding], -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%@",sql);
	}
	else {
		while (sqlite3_step(statement) == SQLITE_ROW) {
			Category *category = [[Category alloc] init];
			category.idx = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			
			const char *categoryName = (const char *) sqlite3_column_text(statement,1);
			
			if (categoryName != NULL) {
				category.name = [NSString stringWithUTF8String:categoryName];
			}
			[data addObject:category];
			[category release];
		}
	}
	return data;
}

+ (void)addCategory:(NSString *)name {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	
	
	const char *sql = "INSERT INTO categories (name, predefined) VALUES (?, 0)";

	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);
	}
	sqlite3_finalize(statement);
}

+ (void)updateCategory:(Category *)category {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	
	
	const char *sql = "UPDATE categories SET name = ? WHERE id = ?";
	
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		sqlite3_bind_text(statement, 1, [category.name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [category.idx UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);
	}
	sqlite3_finalize(statement);
}

+ (void)deleteCategory:(Category *)category {
	sqlite3 *db = [Database getConnection];
	
	NSString *sqlString = [NSString stringWithFormat:@"UPDATE rentIncoming SET type = 3 WHERE type = %@", category.idx];
	sqlite3_exec(db, [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding], NULL, NULL, NULL);
	sqlString = [NSString stringWithFormat:@"UPDATE rentOutgoing SET type = 3 WHERE type = %@", category.idx];
	sqlite3_exec(db, [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding], NULL, NULL, NULL);
	sqlString = [NSString stringWithFormat:@"DELETE FROM categories WHERE id = %@", category.idx];
	sqlite3_exec(db, [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding], NULL, NULL, NULL);
}

+ (LentEntry *)getIncomingEntry:(NSString *)entryId {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	LentEntry *entry = [LentEntry alloc];
	
	NSString *sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentIncoming NATURAL LEFT JOIN incomingText where id=?;";
		
	const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			
			entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
			NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
			NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
			NSString *pushAlarmString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 11)];
			
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
			entry.date = [dateFormat dateFromString:dateString];  
			entry.returnDate = [dateFormat dateFromString:returnDateString];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
			[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
			entry.pushAlarm = [dateFormat dateFromString:pushAlarmString];
			[dateFormat release];
		}
	}
	sqlite3_finalize(statement);

	return entry;
}

+ (LentList *)getIncomingEntries:(NSString *)searchText {
	LentList *list = [[LentList alloc] init];
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSArray *categories = [Database getAllCategories];
	for (int i = 0; i < [categories count]; i++) {
		int idx = [[[categories objectAtIndex:i] idx] intValue];
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];
		NSString *sqlString;
		NSString *filter;
	
		if (searchText == nil || [searchText length] == 0) {
			
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentIncoming NATURAL LEFT JOIN incomingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", idx];
			
			sqlString = [sqlString stringByAppendingString:@"' order by name;"];
		}
		else {
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentIncoming NATURAL LEFT JOIN incomingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", idx];
			sqlString = [sqlString stringByAppendingString:@"' AND (name LIKE ? OR personName LIKE ?) order by name;"];
		}
	
		const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"%s",sql);
		}
		else {
			filter = [NSString stringWithFormat:@"%%%@%%", searchText];
			sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [filter UTF8String], -1, SQLITE_TRANSIENT);
			while (sqlite3_step(statement) == SQLITE_ROW) {
				LentEntry *entry = [LentEntry alloc];
				entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
				entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
				NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
				NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
				NSString *pushAlarmString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 11)];
				
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
				entry.date = [dateFormat dateFromString:dateString];  
				entry.returnDate = [dateFormat dateFromString:returnDateString];
				[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
				[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
				entry.pushAlarm = [dateFormat dateFromString:pushAlarmString];
				[dateFormat release];
				

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

+ (LentEntry *)getOutgoingEntry:(NSString *)entryId {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	LentEntry *entry = [LentEntry alloc];
	
	NSString *sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentOutgoing NATURAL LEFT JOIN outgoingText where id=?;";
	
	const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
			
			entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
			entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
			NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
			NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
			NSString *pushAlarmString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 11)];
			
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
			entry.date = [dateFormat dateFromString:dateString];  
			entry.returnDate = [dateFormat dateFromString:returnDateString];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
			[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
			entry.pushAlarm = [dateFormat dateFromString:pushAlarmString];
			[dateFormat release];
		}
	}
	sqlite3_finalize(statement);
	
	return entry;
}


+ (LentList *)getOutgoingEntries:(NSString *)searchText {
//	NSLog(@"start getting outgoing entries...");
	LentList *list = [[LentList alloc] init];
	NSMutableArray *data = [[NSMutableArray alloc] init];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSArray *categories = [Database getAllCategories];
	for (int i = 0; i < [categories count]; i++) {
		int idx = [[[categories objectAtIndex:i] idx] intValue];
		statement = nil;
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];
		NSString *sqlString;
		NSString *filter;
		
		if (searchText == nil || [searchText length] == 0) {
			
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentOutgoing NATURAL LEFT JOIN outgoingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", idx];
			
			sqlString = [sqlString stringByAppendingString:@"' order by name;"];
		}
		else {
			sqlString = @"SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentOutgoing NATURAL LEFT JOIN outgoingText where type='";
			sqlString = [sqlString stringByAppendingFormat:@"%i", idx];
			sqlString = [sqlString stringByAppendingString:@"' AND (name LIKE ? OR personName LIKE ?) order by name;"];
		}
		//NSLog(@"%@", sqlString);
		const char* sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
		
		
		if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
			NSLog(@"error preparing statement...");
			NSLog(@"%s",sql);
		}
		else {
			filter = [NSString stringWithFormat:@"%%%@%%", searchText];
			sqlite3_bind_text(statement, 1, [filter UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(statement, 2, [filter UTF8String], -1, SQLITE_TRANSIENT);
			while (sqlite3_step(statement) == SQLITE_ROW) {
				LentEntry *entry = [LentEntry alloc];
				entry.entryId = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)];
				entry.type = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 1)];
				NSString *dateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 5)];
				NSString *returnDateString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 6)];
				NSString *pushAlarmString = [NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 11)];
				
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
				entry.date = [dateFormat dateFromString:dateString];  
				entry.returnDate = [dateFormat dateFromString:returnDateString];
				[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
				[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
				entry.pushAlarm = [dateFormat dateFromString:pushAlarmString];
				[dateFormat release];
				
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
	
+ (NSString *)addOutgoingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm {
//	NSLog(@"Add entry...");
	sqlite3 *db = [Database getConnection];
	const char *sql;
	
	sqlite3_stmt *addStmt = nil;
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormat stringFromDate:date];
	NSString *returnDateString = [dateFormat stringFromDate:returnDate];
	[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
	NSString *pushAlarmString = [dateFormat stringFromDate:pushAlarm];
	
	if([entryId intValue] > 0) {
		sql = "insert or replace into rentOutgoing(id, type, description1, description2, person, date, returnDate, pushAlarm) Values(?, ?, ?, ?, ?, ?, ?, ?)";
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
		sqlite3_bind_text(addStmt, 8, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
	}
	else {
		sql = "insert or replace into rentOutgoing(type, description1, description2, person, date, returnDate, pushAlarm) Values(?, ?, ?, ?, ?, ?, ?)";
		if(sqlite3_prepare_v2(db, sql, -1, &addStmt, NULL) != SQLITE_OK) {
			//NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(db));
		}
		sqlite3_bind_text(addStmt, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 2, [((description1 != NULL) ? description1 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 3, [((description2 != NULL) ? description2 : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 4, [((person != NULL) ? person : @"") UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 5, [dateString UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 6, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(addStmt, 7, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
	}	
	
	if(SQLITE_DONE != sqlite3_step(addStmt)) {
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	
	if ([entryId intValue] <= 0) {
		entryId = [[NSString alloc] initWithFormat:@"%i", sqlite3_last_insert_rowid(db)];
	}
	
	sqlite3_reset(addStmt);
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	dateString = [formatter stringForObjectValue:date];
	[formatter release];
	
	[dateFormat release];
	
	NSString *firstLine = @"";
	NSString *secondLine = @"";
	
	if ([description1 length] == 0 || [description2 length] == 0) {
		if ([description1 length] == 0 ) {
			firstLine = [NSString stringWithFormat:@"%@", description2];
		}
		else {
			firstLine = [NSString stringWithFormat:@"%@", description1];
		}
	}
	else {
		firstLine = [NSString stringWithFormat:@"%@ - %@", description1, description2];
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
			personName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		}
		fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
	}
	else {
		if ([person length] > 0) {
			personName = person;
			fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
		}
	}
	
	if (date != nil) {
		if ([fullName length] > 0) {
			secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), dateString, fullName];
		}
		else {
			secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), dateString];
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
	
	return entryId;
}

+ (NSString *)addIncomingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm {
//	NSLog(@"Add entry...");
	sqlite3 *db = [Database getConnection];
	const char *sql;
	
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormat stringFromDate:date];
	NSString *returnDateString = [dateFormat stringFromDate:returnDate];
	
	[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
	[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
	NSString *pushAlarmString = [dateFormat stringFromDate:pushAlarm];
	
	sqlite3_stmt *addStmt = nil;
	
	if ([entryId intValue] > 0) {
		sql = "insert or replace into rentIncoming(id, type, description1, description2, person, date, returnDate, pushAlarm) Values(?, ?, ?, ?, ?, ?, ?, ?)";

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
		sqlite3_bind_text(addStmt, 8, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
	}
	else {
		sql = "insert or replace into rentIncoming(type, description1, description2, person, date, returnDate, pushAlarm) Values(?, ?, ?, ?, ?, ?, ?)";
		
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
		sqlite3_bind_text(addStmt, 7, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
	}
	
	if(SQLITE_DONE != sqlite3_step(addStmt)){
		//NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(db));
	}
	sqlite3_reset(addStmt);

	if ([entryId intValue] <= 0) {
			entryId = [[NSString alloc] initWithFormat:@"%i", sqlite3_last_insert_rowid(db)];
	}
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterNoStyle];
	dateString = [formatter stringForObjectValue:returnDate];
	[formatter release];
	
	[dateFormat release];
	
	NSString *firstLine = @"";
	NSString *secondLine = @"";
	
	if ([description1 length] == 0 || [description2 length] == 0) {
		if ([description1 length] == 0 ) {
			firstLine = [NSString stringWithFormat:@"%@", description2];
		}
		else {
			firstLine = [NSString stringWithFormat:@"%@", description1];
		}
	}
	else {
		firstLine = [NSString stringWithFormat:@"%@ - %@", description1, description2];
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
			personName = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
		}
		fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
	}
	else {
		if ([person length] > 0) {
			personName = person;
			fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"from", @""), personName];
		}
	}
	
	if (returnDate != nil) {
		if ([fullName length] > 0) {
			secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"until", @""), dateString, fullName];
		}
		else {
			secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"until", @""), dateString];
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
	
	return entryId;
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
	
	NSString *sqlString;
	
	sqlString = [NSString stringWithFormat:@"SELECT returnDate from rentIncoming WHERE returnDate <= date();"];
	const char *sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
	}
	else {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		while (sqlite3_step(statement) == SQLITE_ROW) {
			if ([dateFormat dateFromString:[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)]]) {
				count++;
			}
		}
	}
	sqlite3_finalize(statement);
	return count;
}

+ (int)getOutgoingCount {
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement = nil;
	
	NSString *sqlString;
	
	sqlString = [NSString stringWithFormat:@"SELECT returnDate from rentOutgoing WHERE returnDate <= date();"];
	
	const char *sql = [sqlString cStringUsingEncoding:NSISOLatin1StringEncoding]; 
	
	if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) != SQLITE_OK) {
		//NSAssert1(0, @"Error preparing statement...", sqlite3_errmsg(db));
		NSLog(@"%s",sql);
		NSLog(@"%s",sqlite3_errmsg(db));
	}
	else {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		while (sqlite3_step(statement) == SQLITE_ROW) {
			if ([dateFormat dateFromString:[NSString stringWithFormat:@"%s", (char*)sqlite3_column_text(statement, 0)]]) {
				count++;
			}
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


@end
