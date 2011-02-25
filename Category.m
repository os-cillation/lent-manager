//
//  Category.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Category.h"


@implementation Category

@synthesize idx;
@synthesize name;

- (void)dealloc {
	[idx release];
	[name release];
	[super dealloc];
}

@end
