//
//  Category.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Category : NSObject {
	NSString *idx;
	NSString *name;
}

@property (nonatomic, retain) NSString *idx;
@property (nonatomic, retain) NSString *name;

@end
