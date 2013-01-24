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

#import <AddressBook/AddressBook.h>
#import "Category.h"
#import "Database.h"
#import "LentEntry.h"
#import "NSDateFormatter+DateFormatter.h"


@interface NSString (SQLite3Additions)

+ (NSString *)stringFromColumn:(NSUInteger)column ofStatement:(sqlite3_stmt *)statement;

@end


@implementation NSString (SQLite3Additions)

+ (NSString *)stringFromColumn:(NSUInteger)column ofStatement:(sqlite3_stmt *)statement
{
    NSString *string = nil;
    if (statement) {
        const char *text = (const char *)sqlite3_column_text(statement, column);
        if (text) {
            string = [self stringWithUTF8String:text];
        }
    }
    return string;
}

@end


@implementation Database

static sqlite3 *connection = NULL;

+ (void)createEditableCopyOfDatabaseIfNeeded {
	//NSLog(@"Creating editable copy of database...");

	BOOL success;
	NSFileManager *fileManager = [NSFileManager alloc];
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"data.sqlite"];
	success = [fileManager fileExistsAtPath:writableDBPath];
	if (success) {
        [fileManager release];
        return;   
    }
	//[fileManager removeItemAtPath:writableDBPath error:&error];
	// The writeable database does not exist, so copy the default to the appropriate location
	NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.sqlite"];

	success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
	if (!success) {
		// NSAssert1(0, @"Failed to create writeable database file with message'%@'.", [error localizedDescription]);
	}
	[fileManager release];
}

+ (sqlite3 *)getNewDBConnection {
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

+ (void)prepareContactInfo
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	sqlite3 *db = connection;
	sqlite3_stmt *statement;
    
    sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS contactInfo(id INTEGER PRIMARY KEY, name TEXT)", NULL, NULL, NULL);
	sqlite3_exec(db, "BEGIN", NULL, NULL, NULL);
    sqlite3_exec(db, "DELETE FROM contactInfo", NULL, NULL, NULL);
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	if (addressBook) {
        NSArray *contacts = [(NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook) autorelease];
        for (CFIndex i = 0; i < [contacts count]; ++i) {
            ABRecordRef person = (ABRecordRef)[contacts objectAtIndex:i];
            NSString *personName = [(NSString *)ABRecordCopyCompositeName(person) autorelease];
            if ([personName length]) {
                if (sqlite3_prepare_v2(db, "INSERT INTO contactInfo (id, name) VALUES (?, ?)", -1, &statement, NULL) == SQLITE_OK) {
                    sqlite3_bind_int(statement, 1, ABRecordGetRecordID(person));
                    sqlite3_bind_text(statement, 2, [personName UTF8String], -1, SQLITE_TRANSIENT);
                    sqlite3_step(statement);
                    sqlite3_finalize(statement);
                }
            }
        }
        
        CFRelease(addressBook);
    }
    
    sqlite3_exec(db, "COMMIT", NULL, NULL, NULL);
    
    [pool release];
}

+ (ContactEntry *)getContactInfo:(NSString *)filter atIndex:(int)index
{
    ContactEntry *contactEntry = nil;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "SELECT id, name FROM contactInfo WHERE name LIKE ? ORDER BY name LIMIT ?, 1", -1, &statement, NULL) == SQLITE_OK) {
        if ([filter length]) {
            sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_TRANSIENT);
        }
        else {
            sqlite3_bind_text(statement, 1, "%", -1, SQLITE_STATIC);
        }
        sqlite3_bind_int(statement, 2, index);
        if (sqlite3_step(statement) == SQLITE_ROW) {
            contactEntry = [[[ContactEntry alloc] init] autorelease];
            contactEntry.entryId = [NSString stringFromColumn:0 ofStatement:statement];
            contactEntry.name = [NSString stringFromColumn:1 ofStatement:statement];
        }
        sqlite3_finalize(statement);
    }
    
    return contactEntry;
}

+ (int)getContactCount:(NSString *)filter
{
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "SELECT count(*) FROM contactInfo WHERE name LIKE ?", -1, &statement, NULL) == SQLITE_OK) {
        if ([filter length]) {
            sqlite3_bind_text(statement, 1, [[NSString stringWithFormat:@"%%%@%%", filter] UTF8String], -1, SQLITE_TRANSIENT);
        }
        else {
            sqlite3_bind_text(statement, 1, "%", -1, SQLITE_STATIC);
        }
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
	return count;
}

+ (NSString *)getDescriptionByIndex:(int)index
{
	NSString *description = NSLocalizedString(@"Other", @"");
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "SELECT name, preDefined FROM categories WHERE id = ?", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_int(statement, 1, index);
        if (sqlite3_step(statement) == SQLITE_ROW) {
            description = [NSString stringFromColumn:0 ofStatement:statement];
            if (sqlite3_column_int(statement, 1)) {
                description = NSLocalizedString(description, @"");
            }
        }
        sqlite3_finalize(statement);
    }
	return description;
}

+ (int)getCategoryCount
{
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT count(*) FROM categories", -1, &statement, NULL) == SQLITE_OK) {
		if (sqlite3_step(statement) == SQLITE_ROW) {
			count = sqlite3_column_int(statement, 0);
		}
        sqlite3_finalize(statement);
	}
	return count;
}

+ (NSArray *)getAllCategories
{
    NSMutableArray *categories = [NSMutableArray array];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "SELECT id, name, preDefined FROM categories", -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Category *category = [[Category alloc] init];
            category.index = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
            category.name = [NSString stringFromColumn:1 ofStatement:statement] ?: @"";
            if (sqlite3_column_int(statement, 2)) {
                category.name = NSLocalizedString(category.name, @"");
            }
            [categories addObject:category];
            [category release];
        }
        sqlite3_finalize(statement);
    }
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [categories sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    return categories;
}

+ (Category *)getCategory:(NSString *)idx
{
	Category *category = [[[Category alloc] init] autorelease];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT id, name, preDefined FROM categories WHERE id = ? ORDER BY name ASC", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [idx UTF8String], -1, SQLITE_TRANSIENT);
		while (sqlite3_step(statement) == SQLITE_ROW) {
            category.index = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
            category.name = [NSString stringFromColumn:1 ofStatement:statement] ?: @"";
            if (sqlite3_column_int(statement, 2)) {
                category.name = NSLocalizedString(category.name, @"");
            }
		}
        sqlite3_finalize(statement);
	}
	return category;
}

+ (NSArray *)getAllOwnCategories
{
    NSMutableArray *categories = [NSMutableArray array];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "SELECT id, name, preDefined FROM categories WHERE preDefined = 0", -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Category *category = [[Category alloc] init];
            category.index = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
            category.name = [NSString stringFromColumn:1 ofStatement:statement] ?: @"";
            if (sqlite3_column_int(statement, 2)) {
                category.name = NSLocalizedString(category.name, @"");
            }
            [categories addObject:category];
            [category release];
        }
        sqlite3_finalize(statement);
    }
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [categories sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    return categories;
}

+ (void)addCategory:(NSString *)name
{
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "INSERT INTO categories (name, predefined) VALUES (?, 0)", -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_text(statement, 1, [name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);
        sqlite3_finalize(statement);
	}
}

+ (void)updateCategory:(Category *)category
{
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "UPDATE categories SET name = ? WHERE id = ?", -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_text(statement, 1, [category.name UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(statement, 2, [category.index UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_step(statement);
        sqlite3_finalize(statement);
	}
}

+ (void)deleteCategory:(Category *)category
{
	sqlite3 *db = [Database getConnection];
    
    sqlite3_exec(db, [[NSString stringWithFormat:@"UPDATE rentIncoming SET type = 3 WHERE type = %@", category.index] UTF8String], NULL, NULL, NULL);
    sqlite3_exec(db, [[NSString stringWithFormat:@"UPDATE rentOutgoing SET type = 3 WHERE type = %@", category.index] UTF8String], NULL, NULL, NULL);
    sqlite3_exec(db, [[NSString stringWithFormat:@"DELETE FROM categories WHERE id = %@", category.index] UTF8String], NULL, NULL, NULL);
}

+ (LentEntry *)getIncomingEntry:(NSString *)entryId
{
	LentEntry *entry = [[[LentEntry alloc] init] autorelease];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentIncoming NATURAL LEFT JOIN incomingText where id=?", -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
            entry.entryId = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
            entry.type = [NSString stringFromColumn:1 ofStatement:statement];
            entry.description = [NSString stringFromColumn:2 ofStatement:statement];
            entry.description2 = [NSString stringFromColumn:3 ofStatement:statement];
            entry.person = [NSString stringFromColumn:4 ofStatement:statement];
            entry.firstLine = [NSString stringFromColumn:7 ofStatement:statement];
            entry.secondLine = [NSString stringFromColumn:8 ofStatement:statement];
            entry.personName = [NSString stringFromColumn:9 ofStatement:statement];
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
			entry.date = [dateFormat dateFromString:[NSString stringFromColumn:5 ofStatement:statement]];  
			entry.returnDate = [dateFormat dateFromString:[NSString stringFromColumn:6 ofStatement:statement]];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
			[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
			entry.pushAlarm = [dateFormat dateFromString:[NSString stringFromColumn:11 ofStatement:statement]];
			[dateFormat release];
		}
        sqlite3_finalize(statement);
	}
	return entry;
}

+ (LentList *)getIncomingEntries:(NSString *)searchText
{
	NSMutableArray *data = [NSMutableArray array];
	sqlite3 *db = [Database getConnection];
    for (Category *category in [self getAllCategories]) {
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];

        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, "SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) AS name, pushAlarm FROM rentIncoming NATURAL LEFT JOIN incomingText WHERE type = ? AND (name LIKE ? OR personName LIKE ?) ORDER BY name", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, [category.index intValue]);
            if ([searchText length]) {
                NSString *pattern = [[NSString alloc] initWithFormat:@"%%%@%%", searchText];
                sqlite3_bind_text(statement, 2, [pattern UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 3, [pattern UTF8String], -1, SQLITE_TRANSIENT);
                [pattern release];
            }
            else {
                sqlite3_bind_text(statement, 2, "%", -1, SQLITE_STATIC);
                sqlite3_bind_text(statement, 3, "%", -1, SQLITE_STATIC);
            }
            
			while (sqlite3_step(statement) == SQLITE_ROW) {
				LentEntry *entry = [[LentEntry alloc] init];
                entry.entryId = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
                entry.type = [NSString stringFromColumn:1 ofStatement:statement];
                entry.description = [NSString stringFromColumn:2 ofStatement:statement];
                entry.description2 = [NSString stringFromColumn:3 ofStatement:statement];
                entry.person = [NSString stringFromColumn:4 ofStatement:statement];
                entry.firstLine = [NSString stringFromColumn:7 ofStatement:statement];
                entry.secondLine = [NSString stringFromColumn:8 ofStatement:statement];
                entry.personName = [NSString stringFromColumn:9 ofStatement:statement];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                entry.date = [dateFormat dateFromString:[NSString stringFromColumn:5 ofStatement:statement]];  
                entry.returnDate = [dateFormat dateFromString:[NSString stringFromColumn:6 ofStatement:statement]];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
                [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
                entry.pushAlarm = [dateFormat dateFromString:[NSString stringFromColumn:11 ofStatement:statement]];
                [dateFormat release];
				[listEntry addObject:entry];
				[entry release];
			}
            sqlite3_finalize(statement);
		}
		if ([listEntry count]) {
			[data addObject:listEntry];
		}
        [listEntry release];
	}
    return [LentList lentListWithData:data];
}

+ (LentEntry *)getOutgoingEntry:(NSString *)entryId
{
	LentEntry *entry = [[[LentEntry alloc] init] autorelease];
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) as name, pushAlarm from rentOutgoing NATURAL LEFT JOIN outgoingText where id=?", -1, &statement, NULL) == SQLITE_OK) {
		sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
		if (sqlite3_step(statement) == SQLITE_ROW) {
            entry.entryId = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
            entry.type = [NSString stringFromColumn:1 ofStatement:statement];
            entry.description = [NSString stringFromColumn:2 ofStatement:statement];
            entry.description2 = [NSString stringFromColumn:3 ofStatement:statement];
            entry.person = [NSString stringFromColumn:4 ofStatement:statement];
            entry.firstLine = [NSString stringFromColumn:7 ofStatement:statement];
            entry.secondLine = [NSString stringFromColumn:8 ofStatement:statement];
            entry.personName = [NSString stringFromColumn:9 ofStatement:statement];
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd"];
			entry.date = [dateFormat dateFromString:[NSString stringFromColumn:5 ofStatement:statement]];  
			entry.returnDate = [dateFormat dateFromString:[NSString stringFromColumn:6 ofStatement:statement]];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
			[dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
			entry.pushAlarm = [dateFormat dateFromString:[NSString stringFromColumn:11 ofStatement:statement]];
			[dateFormat release];
		}
        sqlite3_finalize(statement);
	}
	return entry;
}

+ (LentList *)getOutgoingEntries:(NSString *)searchText
{
	NSMutableArray *data = [NSMutableArray array];
	sqlite3 *db = [Database getConnection];
    for (Category *category in [self getAllCategories]) {
		NSMutableArray *listEntry = [[NSMutableArray alloc] init];
        
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(db, "SELECT id, type, description1, description2, person, date, returnDate, firstLine, secondLine, personName, (description1 || description2) AS name, pushAlarm FROM rentOutgoing NATURAL LEFT JOIN outgoingText WHERE type = ? AND (name LIKE ? OR personName LIKE ?) ORDER BY name", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_int(statement, 1, [category.index intValue]);
            if ([searchText length]) {
                NSString *pattern = [[NSString alloc] initWithFormat:@"%%%@%%", searchText];
                sqlite3_bind_text(statement, 2, [pattern UTF8String], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(statement, 3, [pattern UTF8String], -1, SQLITE_TRANSIENT);
                [pattern release];
            }
            else {
                sqlite3_bind_text(statement, 2, "%", -1, SQLITE_STATIC);
                sqlite3_bind_text(statement, 3, "%", -1, SQLITE_STATIC);
            }
            
			while (sqlite3_step(statement) == SQLITE_ROW) {
				LentEntry *entry = [[LentEntry alloc] init];
                entry.entryId = [[NSNumber numberWithLongLong:sqlite3_column_int64(statement, 0)] stringValue];
                entry.type = [NSString stringFromColumn:1 ofStatement:statement];
                entry.description = [NSString stringFromColumn:2 ofStatement:statement];
                entry.description2 = [NSString stringFromColumn:3 ofStatement:statement];
                entry.person = [NSString stringFromColumn:4 ofStatement:statement];
                entry.firstLine = [NSString stringFromColumn:7 ofStatement:statement];
                entry.secondLine = [NSString stringFromColumn:8 ofStatement:statement];
                entry.personName = [NSString stringFromColumn:9 ofStatement:statement];
                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"yyyy-MM-dd"];
                entry.date = [dateFormat dateFromString:[NSString stringFromColumn:5 ofStatement:statement]];  
                entry.returnDate = [dateFormat dateFromString:[NSString stringFromColumn:6 ofStatement:statement]];
                [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
                [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
                entry.pushAlarm = [dateFormat dateFromString:[NSString stringFromColumn:11 ofStatement:statement]];
                [dateFormat release];
				[listEntry addObject:entry];
				[entry release];
			}
            sqlite3_finalize(statement);
		}
		if ([listEntry count]) {
			[data addObject:listEntry];
		}
        [listEntry release];
	}
    return [LentList lentListWithData:data];
}
	
+ (NSString *)addOutgoingEntry:(NSString *)entryId withType:(NSString *)type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormatter stringFromDate:date];
	NSString *returnDateString = [dateFormatter stringFromDate:returnDate];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	NSString *pushAlarmString = [dateFormatter stringFromDate:pushAlarm];
    [dateFormatter release];
	
	if ([entryId intValue] > 0) {
		if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO rentOutgoing (id, type, description1, description2, person, date, returnDate, pushAlarm) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);	
            sqlite3_bind_text(statement, 2, [type UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [(description1 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [(description2 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [(person ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [dateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
	}
	else {
		if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO rentOutgoing (type, description1, description2, person, date, returnDate, pushAlarm) VALUES (?, ?, ?, ?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [(description1 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [(description2 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [(person ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [dateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            
            entryId = [[NSNumber numberWithLongLong:sqlite3_last_insert_rowid(db)] stringValue];
        }
	}	
	
    dateString = [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:date];;

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
	
	NSString *fullName = @"";
	NSString *personName = @"";
	ABAddressBookRef addressBook = ABAddressBookCreate();
    if (addressBook) {
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, [person intValue]);
        if (record) {
            personName = [(NSString *)ABRecordCopyCompositeName(record) autorelease];
        }
        else if ([person length]) {
            personName = person;
        }
        if (personName) {
            fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
        }            
        
        CFRelease(addressBook);
    }
	
	if (date) {
		if ([fullName length]) {
			secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), dateString, fullName];
		}
		else {
			secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), dateString];
		}
	}
	else {
		secondLine = fullName;
	}
	
    if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO outgoingText (id, firstLine, secondLine, personName) VALUES (?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [(firstLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [(secondLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [(personName ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
	return entryId;
}

+ (NSString *)addIncomingEntry:(NSString *)entryId withType:(NSString *)type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm {
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *dateString = [dateFormatter stringFromDate:date];
	NSString *returnDateString = [dateFormatter stringFromDate:returnDate];
	[dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
	NSString *pushAlarmString = [dateFormatter stringFromDate:pushAlarm];
    [dateFormatter release];
	
	if ([entryId intValue] > 0) {
		if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO rentIncoming (id, type, description1, description2, person, date, returnDate, pushAlarm) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);	
            sqlite3_bind_text(statement, 2, [type UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [(description1 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [(description2 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [(person ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [dateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
        }
	}
	else {
		if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO rentIncoming (type, description1, description2, person, date, returnDate, pushAlarm) VALUES (?, ?, ?, ?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [(description1 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [(description2 ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [(person ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [dateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [returnDateString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [pushAlarmString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_step(statement);
            sqlite3_finalize(statement);
            
            entryId = [[NSNumber numberWithLongLong:sqlite3_last_insert_rowid(db)] stringValue];
        }
	}	
	
    dateString = [[NSDateFormatter dateFormatterForShortStyle] stringFromDate:date];;
    
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
	
	NSString *fullName = @"";
	NSString *personName = @"";
	ABAddressBookRef addressBook = ABAddressBookCreate();
    if (addressBook) {
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, [person intValue]);
        if (record) {
            personName = [(NSString *)ABRecordCopyCompositeName(record) autorelease];
        }
        else if ([person length]) {
            personName = person;
        }
        if ([personName length]) {
            fullName = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"to", @""), personName];
        }            
        
        CFRelease(addressBook);
    }
	
	if (date) {
		if ([fullName length]) {
			secondLine = [NSString stringWithFormat:@"%@ %@, %@", NSLocalizedString(@"at", @""), dateString, fullName];
		}
		else {
			secondLine = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"at", @""), dateString];
		}
	}
	else {
		secondLine = fullName;
	}
	
    if (sqlite3_prepare_v2(db, "INSERT OR REPLACE INTO incomingText (id, firstLine, secondLine, personName) VALUES (?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [entryId UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [(firstLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [(secondLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [(personName ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
	
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
	sqlite3_finalize(stmt);
	
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
	sqlite3_finalize(stmt);
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

+ (int)getIncomingCount
{
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT returnDate from rentIncoming WHERE returnDate <= date()", -1, &statement, NULL) == SQLITE_OK) {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		while (sqlite3_step(statement) == SQLITE_ROW) {
            if ([dateFormat dateFromString:[NSString stringFromColumn:0 ofStatement:statement]]) {
				count++;
			}
		}
        [dateFormat release];
        sqlite3_finalize(statement);
	}
	return count;
}

+ (int)getOutgoingCount
{
	int count = 0;
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
	if (sqlite3_prepare_v2(db, "SELECT returnDate from rentOutgoing WHERE returnDate <= date()", -1, &statement, NULL) == SQLITE_OK) {
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		while (sqlite3_step(statement) == SQLITE_ROW) {
            if ([dateFormat dateFromString:[NSString stringFromColumn:0 ofStatement:statement]]) {
				count++;
			}
		}
        [dateFormat release];
        sqlite3_finalize(statement);
	}
	return count;
}

+ (int)getEntryCount
{
    return [Database getIncomingCount] + [Database getOutgoingCount];
}

+ (void)addIncomingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName 
{
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "INSERT INTO incomingText (id, firstLine, secondLine, personName) VALUES (?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [(firstLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [(secondLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [(personName ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

+ (void)addOutgoingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName
{
	sqlite3 *db = [Database getConnection];
	sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(db, "INSERT INTO outgoingText (id, firstLine, secondLine, personName) VALUES (?, ?, ?, ?)", -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [id UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [(firstLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [(secondLine ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [(personName ?: @"") UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
}

@end
