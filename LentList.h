//
//  LentList.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LentEntry.h"


@interface LentList : NSObject {
	NSMutableArray *data;
}

- (NSInteger)getSectionCount;
- (NSInteger)getEntryCount:(int)section;
- (void)setData:(NSMutableArray *)pData;
- (NSMutableArray *)getData;
- (LentEntry *)getSectionData:(NSInteger)section atRow:(NSInteger)row;
@end
