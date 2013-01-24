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
