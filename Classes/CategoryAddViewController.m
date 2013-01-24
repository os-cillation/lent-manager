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

#import "CategoryAddViewController.h"
#import "Database.h"
#import "Category.h"

@implementation CategoryAddViewController

@synthesize category;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (category) {
		self.title = NSLocalizedString(@"Edit", @"");
	}
	else {
		self.title = NSLocalizedString(@"NewEntry", @"");
	}

	labelName.text = NSLocalizedString(@"NewCategoryName", @"");
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] 
				  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
				  target:self
				  action:@selector(handleCancel)];
	
    self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	
	
	saveButton = [[UIBarButtonItem alloc] 
								  initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								  target:self
								  action:@selector(handleSave)];
    self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	
	if (category) {
		textFieldName.text = category.name;
	}
	else {
		saveButton.enabled = NO;
	}

	
	[textFieldName addTarget:self action:@selector(textFieldDidChange) forControlEvents:UIControlEventEditingChanged];
	[textFieldName becomeFirstResponder];
}

- (void)textFieldDidChange {
	saveButton.enabled = ([textFieldName.text length] > 0);
}

- (void)handleCancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)handleSave {
	if (category) {
		category.name = textFieldName.text;
		[Database updateCategory:category];
	}
	else {
		[Database addCategory:textFieldName.text];
	}

	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[category release];
    [super dealloc];
}


@end
