//
//  DateSelectViewController.m
//  iVerleih
//
//  Created by Benjamin Mies on 15.03.10.
//  Copyright 2010 os-cillation e.K.. All rights reserved.
//

#import "DateSelectViewController.h"


@implementation DateSelectViewController

@synthesize delegate, datePicker, date;

- (IBAction)done {
	[delegate dateSelectViewControllerDidFinish:self];
}

- (IBAction)cancel {
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.date = self.date ?: [NSDate date];
	[self.datePicker setDate:self.date animated:NO];
}

- (void)dealloc
{
    [self setDate:nil];
    [super dealloc];
}


@end
