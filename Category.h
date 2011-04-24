//
//  Category.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 os-cillation GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Category : NSObject {
	NSString *_index;
	NSString *_name;
}

@property (nonatomic, copy) NSString *index;
@property (nonatomic, copy) NSString *name;

@end
