//
//  ReturnDateSelectViewController.h
//  iVerleih
//
//  Created by Benjamin Mies on 15.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ReturnDateSelectViewControllerDelegate;

@interface ReturnDateSelectViewController : UIViewController {
	id <ReturnDateSelectViewControllerDelegate> delegate;
	IBOutlet UIDatePicker *datePicker;
	NSDate *date;
}

@property (nonatomic, assign) id <ReturnDateSelectViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) NSDate *date;

- (IBAction)done;
- (IBAction)cancel;

@end

@protocol ReturnDateSelectViewControllerDelegate
- (void)returnDateSelectViewControllerDidFinish:(ReturnDateSelectViewController *)controller;
@end