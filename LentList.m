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

#import "LentList.h"


@implementation LentList

@synthesize data = _data;

+ (LentList *)lentListWithData:(NSArray *)data
{
    LentList *lentList = [[[self alloc] init] autorelease];
    lentList.data = data;
    return lentList;
}

- (void)dealloc
{
    [_data release], _data = nil;
    [super dealloc];
}

- (NSUInteger)sectionCount
{
	return [self.data count];
}

- (NSUInteger)entryCountForSection:(int)section
{
	return [[self.data objectAtIndex:section] count];
}

- (LentEntry *)entryForSection:(NSInteger)section atRow:(NSInteger)row
{
    return [[self.data objectAtIndex:section] objectAtIndex:row];
}

@end
