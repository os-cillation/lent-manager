//
//  PickerViewController.h
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickerViewControllerDelegate;

@class Category;


@interface CategoryPickerViewController : UIViewController <UIPickerViewDelegate> {
	id <PickerViewControllerDelegate> delegate;
	NSArray *data;
	IBOutlet UINavigationBar *navBar;
	IBOutlet UIPickerView *pickerView;
	NSString *stringTitle;
	int selectedIndex;
}

@property (nonatomic, assign) id <PickerViewControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *data;
@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, copy) NSString *stringTitle;
@property (nonatomic, assign) int selectedIndex;

- (IBAction)handleDone;
@end

@protocol PickerViewControllerDelegate

- (void)changeCategory:(Category *)category;

@end

