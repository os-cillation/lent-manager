//
//  CategoryAddViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Category;


@interface CategoryAddViewController : UIViewController {
	IBOutlet UILabel *labelName;
	IBOutlet UITextField *textFieldName;
	UIBarButtonItem *saveButton;
	Category *category;
}

@property (nonatomic, retain) Category *category;

@end
