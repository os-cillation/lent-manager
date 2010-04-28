//
//  RentEntry.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RentEntry : NSObject {
	NSString *entryId;
	NSString *type;
	NSString *description;
	NSString *description2;
	NSString *person;
	NSDate *date;
	NSDate *returnDate;
}

@property (nonatomic, retain) NSString *entryId;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *description2;
@property (nonatomic, retain) NSString *person;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *returnDate;

- (NSString *)getDateString;
- (NSString *)getReturnDateString;

@end
