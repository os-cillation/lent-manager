//
//  Database.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LentList.h"
#import "ContactEntry.h"

sqlite3 *connection;

@class Category;

@interface Database : NSObject {

}

+ (void)createEditableCopyOfDatabaseIfNeeded;
+ (sqlite3 *)getConnection;
+ (NSString *)getDescriptionByIndex:(int)index;
+ (NSString *)addOutgoingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm;
+ (NSString *)addIncomingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate withPushAlarm:(NSDate *)pushAlarm;
+ (void)deleteIncomingEntry:(NSString *)entryId;
+ (void)deleteOutgoingEntry:(NSString *)entryId;
+ (LentEntry *)getIncomingEntry:(NSString *)entryId;
+ (LentList *)getIncomingEntries:(NSString *)searchText;
+ (LentEntry *)getOutgoingEntry:(NSString *)entryId;
+ (LentList *)getOutgoingEntries:(NSString *)searchText;

+ (void)prepareContactInfo;
//+ (NSMutableArray *)getContactInfo:(NSString *)filter;
+ (ContactEntry *)getContactInfo:(NSString *)filter atIndex:(int)index;
+ (int)getContactCount:(NSString *)filter;

+ (int)getIncomingCount;
+ (int)getOutgoingCount;
+ (int)getEntryCount;

+ (NSArray *)getAllCategories;
+ (NSMutableArray *)getAllOwnCategories;
+ (Category *)getCategory:(NSString *)idx;
+ (void)addCategory:(NSString *)name;
+ (void)updateCategory:(Category *)category;
+ (void)deleteCategory:(Category *)category;

+ (void)addOutgoingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName;
+ (void)addIncomingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName;

/*
+ (void)updateDB:(sqlite3 *)db;
+ (void)prepareOutgoingText:(sqlite3 *)db;
+ (void)prepareIncomingText:(sqlite3 *)db;
*/
@end
