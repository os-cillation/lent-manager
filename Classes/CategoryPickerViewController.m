//
//  PickerViewController.m
//  LentManager
//
//  Created by Benjamin Mies on 23.02.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

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
