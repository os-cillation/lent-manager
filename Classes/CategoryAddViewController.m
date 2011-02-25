//
//  CategoryAddViewController.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[category release];
    [super dealloc];
}


@end
