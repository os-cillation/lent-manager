//
//  LentList.m
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

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
