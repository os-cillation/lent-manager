//
//  NSDateFormatter+DateFormatter.m
//  LentManager
//
//  Created by Benedikt Meurer on 4/24/11.
//  Copyright 2011 os-cillation GmbH. All rights reserved.
//

#import "NSDateFormatter+DateFormatter.h"


@implementation NSDateFormatter (DateFormatter)

+ (NSDateFormatter *)dateFormatterForShortStyle
{
    return [self dateFormatterForStyle:NSDateFormatterShortStyle];
}

+ (NSDateFormatter *)dateFormatterForStyle:(NSDateFormatterStyle)style
{
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:style];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehaviorDefault];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    return dateFormatter;
}

@end
