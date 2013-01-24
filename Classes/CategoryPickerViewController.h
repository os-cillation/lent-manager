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

