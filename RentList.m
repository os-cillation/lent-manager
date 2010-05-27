//
//  RentList.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "RentList.h"


@implementation RentList

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

- (RentEntry *)getSectionData:(NSInteger)section atRow:(NSInteger)row {
	RentEntry *result = [RentEntry alloc];
	NSMutableArray *array = (NSMutableArray *)[data objectAtIndex:(int)section];
	result = (RentEntry *) [array objectAtIndex:(int)row];
	return result;
}

@end
