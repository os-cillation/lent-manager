//
//  Category.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 os-cillation GmbH. All rights reserved.
//

#import "Category.h"


@implementation Category

@synthesize index = _index;
@synthesize name = _name;

- (void)dealloc
{
    [_index release], _index = nil;
    [_name release], _name = nil;
	[super dealloc];
}

@end
