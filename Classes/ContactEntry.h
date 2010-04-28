//
//  untitled.h
//  LentManager
//
//  Created by Benjamin Mies on 22.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContactEntry : NSObject {
	NSString *entryId;
	NSString *name;
}

@property (nonatomic, copy) NSString *entryId;
@property (nonatomic, copy) NSString *name;

@end
