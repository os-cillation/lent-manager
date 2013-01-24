/*-
 * Copyright 2011 os-cillation GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
