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
	IBOutlet UILabel *labelPush;
	IBOutlet UISwitch *switchPush;
	NSDate *date;
	NSDate *minDate;
	NSDate *pushAlarm;
}

@property (nonatomic, assign) id <ReturnDateSelectViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, retain) IBOutlet UISwitch *switchPush;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSDate *minDate;
@property (nonatomic, retain) NSDate *pushAlarm;

- (IBAction)done;
- (IBAction)cancel;
- (IBAction)handlePushNotificationsChanged;

@end

@protocol ReturnDateSelectViewControllerDelegate
- (void)returnDateSelectViewControllerDidFinish:(ReturnDateSelectViewController *)controller;
@end