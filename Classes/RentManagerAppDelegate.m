//
//  RentManagerAppDelegate.m
//  RentManager
//
//  Created by Benjamin Mies on 17.03.10.
//  Copyright os-cillation e.K. 2010. All rights reserved.
//

#import "RentManagerAppDelegate.h"
#import "Database.h"
#import "RentOutgoingViewController.h"
#import "RentIncomingViewController.h"
#import "AboutViewController.h"


@implementation RentManagerAppDelegate

@synthesize window;
@synthesize tabBarController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[Database createEditableCopyOfDatabaseIfNeeded];   
	RentOutgoingViewController *outgoingController = [[RentOutgoingViewController alloc] initWithNibName:@"RentOutgoingViewController" bundle:nil];
	outgoingController.title = NSLocalizedString(@"LentToTitle", @"");
	outgoingController.tabBarItem.image = [UIImage imageNamed:@"outgoing2.png"];
	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:outgoingController];

	RentIncomingViewController *incomingController = [[RentIncomingViewController alloc] initWithNibName:@"RentIncomingViewController" bundle:nil];
	incomingController.title = NSLocalizedString(@"LentFromTitle", @"");
	incomingController.tabBarItem.image = [UIImage imageNamed:@"incoming2.png"];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:incomingController];
	
	AboutViewController *aboutController = [[AboutViewController alloc] init];
	aboutController.tabBarItem.image = [UIImage imageNamed:@"info2.png"];
	aboutController.title = NSLocalizedString(@"About", @"");
	NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
	[viewControllers addObject:navController1];
	[viewControllers addObject:navController2];
	[viewControllers addObject:aboutController];
	[tabBarController setViewControllers:viewControllers];
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

