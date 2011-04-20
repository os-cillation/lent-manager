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
    [pData retain];
    [data release];
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
	NSMutableArray *array = (NSMutableArray *)[data objectAtIndex:(int)section];
	return (LentEntry *) [array objectAtIndex:(int)row];
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

@end
