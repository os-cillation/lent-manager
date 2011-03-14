//
//  ContactEntry.m
//  LentManager
//
//  Created by Benjamin Mies on 22.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "ContactEntry.h"


@implementation ContactEntry

@synthesize entryId, name;

- (void)dealloc {
	[entryId release];
	[name release];
	[super dealloc];
}

@end
