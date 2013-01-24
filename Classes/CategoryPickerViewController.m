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

#import "CategoryPickerViewController.h"
#import "Category.h"


@implementation CategoryPickerViewController

@synthesize delegate;
@synthesize data;
@synthesize pickerView;
@synthesize stringTitle;
@synthesize selectedIndex;

- (void)viewDidLoad
{
	[super viewDidLoad];
	navBar.topItem.title = self.stringTitle;
	[pickerView selectRow:selectedIndex inComponent:0 animated:YES];
}

- (IBAction)handleDone
{
	[delegate changeCategory:[data objectAtIndex:[pickerView selectedRowInComponent:0]]];
	// [self.view removeFromSuperview]; // nur wenn es als View ohne Controller hinzugefügt wurde
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
	return [data count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[data objectAtIndex:row] name];
}

- (void)dealloc
{
	[data release];
	[stringTitle release];
    [super dealloc];
}


@end
