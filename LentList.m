//
//  LentList.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "LentList.h"


@implementation LentList

- (void)setData:(NSMutableArray *)pData {
	data = pData;
}

- (NSMutableArray *)getData {
	return data;
}

- (NSInteger)getSectionCount {
	return [data count];
}

- (NSInteger)getEntryCount:(int)section {
	
	return [[data objectAtIndex:section] count];
}

- (LentEntry *)getSectionData:(NSInteger)section atRow:(NSInteger)row {
	LentEntry *result = [LentEntry alloc];
	NSMutableArray *array = (NSMutableArray *)[data objectAtIndex:(int)section];
	result = (LentEntry *) [array objectAtIndex:(int)row];
	return result;
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

@end
