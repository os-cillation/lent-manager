//
//  Database.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "RentList.h"
#import "ContactEntry.h"

sqlite3 *connection;

@interface Database : NSObject {

}

+ (void)createEditableCopyOfDatabaseIfNeeded;
+ (sqlite3 *)getConnection;
+ (NSString *)getDescriptionByIndex:(int)index;
+ (void)addOutgoingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate;
+ (void)addIncomingEntry:(NSString *)entryId withType:(NSString *) type withDescription1:(NSString *)description1 withDescription2:(NSString *)description2 forPerson:(NSString *)person withDate:(NSDate *)date withReturnDate:(NSDate *)returnDate;
+ (void)deleteIncomingEntry:(NSString *)entryId;
+ (void)deleteOutgoingEntry:(NSString *)entryId;
+ (RentList *)getIncomingEntries:(NSString *)searchText;
+ (RentList *)getOutgoingEntries:(NSString *)searchText;

+ (void)prepareContactInfo;
//+ (NSMutableArray *)getContactInfo:(NSString *)filter;
+ (ContactEntry *)getContactInfo:(NSString *)filter atIndex:(int)index;
+ (int)getContactCount:(NSString *)filter;

+ (int)getIncomingCount;
+ (int)getOutgoingCount;
+ (int)getEntryCount;

+ (void)addOutgoingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName;
+ (void)addIncomingText:(NSString *)id withFirstLine:(NSString *)firstLine withSecondLine:(NSString *)secondLine withPerson:(NSString *)personName;

/*
+ (void)updateDB:(sqlite3 *)db;
+ (void)prepareOutgoingText:(sqlite3 *)db;
+ (void)prepareIncomingText:(sqlite3 *)db;
*/
@end
