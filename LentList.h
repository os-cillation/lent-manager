//
//  LentList.h
//  iVerleih
//
//  Created by Benjamin Mies on 13.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LentEntry;

@interface LentList : NSObject {
    NSArray *_data;
}

@property (nonatomic, copy) NSArray *data;

+ (LentList *)lentListWithData:(NSArray *)data;

- (NSUInteger)sectionCount;
- (NSUInteger)entryCountForSection:(int)section;
- (LentEntry *)entryForSection:(NSInteger)section atRow:(NSInteger)row;

@end
