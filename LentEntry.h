//
//  LentEntry.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LentEntry : NSObject {
	NSString *_entryId;
	NSString *_type;
	NSString *_description;
	NSString *_description2;
	NSString *_person;
	NSDate *_date;
	NSDate *_returnDate;
	NSString *_firstLine;
	NSString *_secondLine;
	NSString *_personName;
	NSDate *_pushAlarm;
}

@property (nonatomic, copy) NSString *entryId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *description2;
@property (nonatomic, copy) NSString *person;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *returnDate;
@property (nonatomic, copy) NSString *firstLine;
@property (nonatomic, copy) NSString *secondLine;
@property (nonatomic, copy) NSString *personName;
@property (nonatomic, retain) NSDate *pushAlarm;

@property (nonatomic, readonly) NSString *dateString;
@property (nonatomic, readonly) NSString *returnDateString;

- (void)generateOutgoingText;
- (void)generateIncomingText;

@end
