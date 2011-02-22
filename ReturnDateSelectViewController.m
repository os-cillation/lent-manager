//
//  ReturnDateSelectViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 15.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "ReturnDateSelectViewController.h"


@implementation ReturnDateSelectViewController

@synthesize delegate, datePicker, date, minDate;

- (IBAction)done {
	[delegate returnDateSelectViewControllerDidFinish:self];
}

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.datePicker.minimumDate = minDate;
	if (self.date == nil) {
		self.date = [NSDate date];
	}
	if ([self.date compare:minDate] == NSOrderedAscending) {
		[self.datePicker setDate:minDate animated:NO];
	}
	else {
		[self.datePicker setDate:self.date animated:NO];
	}

	
	

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
	//[datePicker release];
	[date release];
}


@end
