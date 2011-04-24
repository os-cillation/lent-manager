//
//  CategoryTableViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CategoryTableViewController : UITableViewController {
	NSArray *_categories;
	UIBarButtonItem *_editButton;
}

@property (nonatomic, copy) NSArray *categories;
@property (nonatomic, retain) UIBarButtonItem *editButton;

@end
