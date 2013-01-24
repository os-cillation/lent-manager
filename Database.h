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

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "LentList.h"
#import "ContactEntry.h"


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
+ (NSArray *)getAllOwnCategories;
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
