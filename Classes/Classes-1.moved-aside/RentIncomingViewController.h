//
//  RootViewController.h
//  iVerleih
//
//  Created by Benjamin Mies on 12.03.10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//
#import "RentList.h"


@interface RentOutgoingViewController : UITableViewController <UITextFieldDelegate> {
	NSMutableArray *tableData;
	RentList *list;
}

- (void)add;
- (IBAction)showAboutDialog;

@end
