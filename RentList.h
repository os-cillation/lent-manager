//
//  RentList.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RentEntry.h"


@interface RentList : NSObject {
	NSMutableArray *data;
}

- (NSInteger)getSectionCount;
- (NSInteger)getEntryCount:(int)section;
- (void)setData:(NSMutableArray *)pData;
- (RentEntry *)getSectionData:(NSInteger)section atRow:(NSInteger)row;
@end
