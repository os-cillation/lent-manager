//
//  NSDateFormatter+DateFormatter.h
//  LentManager
//
//  Created by Benedikt Meurer on 4/24/11.
//  Copyright 2011 os-cillation GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDateFormatter (DateFormatter)

+ (NSDateFormatter *)dateFormatterForShortStyle;
+ (NSDateFormatter *)dateFormatterForStyle:(NSDateFormatterStyle)style;

@end
