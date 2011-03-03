//
//  PersonViewController.m
//  Group
//
//  Created by Benjamin Mies on 26.05.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PersonViewController.h"

@implementation PersonViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = nil;
	UIBarButtonItem *cancelButton =  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																				   target:self action:@selector(cancelContact)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	self.navigationItem.rightBarButtonItem = nil;
		
	[cancelButton release];
	self.allowsEditing = NO;
}

- (void)cancelContact {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
    [super dealloc];
}


@end
