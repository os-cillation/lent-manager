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
	
	NSString *      initialDefaultsPath;
	NSDictionary *  initialDefaults;
    
	initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
	
	initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
	
	[Database createEditableCopyOfDatabaseIfNeeded];   
	outgoingController = [[RentOutgoingViewController alloc] initWithNibName:@"RentOutgoingViewController" bundle:nil];
	outgoingController.title = NSLocalizedString(@"LentToTitle", @"");
	outgoingController.tabBarItem.image = [UIImage imageNamed:@"outgoing2.png"];
	
	int count = [Database getOutgoingCount];
	if (count > 0) {
		outgoingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}

	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:outgoingController];

	incomingController = [[RentIncomingViewController alloc] initWithNibName:@"RentIncomingViewController" bundle:nil];
	incomingController.title = NSLocalizedString(@"LentFromTitle", @"");
	incomingController.tabBarItem.image = [UIImage imageNamed:@"incoming2.png"];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:incomingController];
	
	count = [Database getIncomingCount];
	if (count > 0) {
		incomingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", count];
	}
	
	AboutViewController *aboutController = [[AboutViewController alloc] init];
	aboutController.tabBarItem.image = [UIImage imageNamed:@"info2.png"];
	aboutController.title = NSLocalizedString(@"About", @"");
	NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
	[viewControllers addObject:navController1];
	[viewControllers addObject:navController2];
	[viewControllers addObject:aboutController];
	[tabBarController setViewControllers:viewControllers];
//	tabBarController.delegate = self;
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
}

- (void)updateBadging {
	outgoingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", [Database getOutgoingCount]];
	incomingController.tabBarItem.badgeValue = [[NSString alloc] initWithFormat:@"%i", [Database getIncomingCount]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	int count = [Database getEntryCount];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

@end

